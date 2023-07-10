library(tidyverse)
library(shinydashboard)
library(shiny)
library(shinyjs)
library(bs4Dash)
library(wordcloud2)
library(plotly)
library(markdown)
library(DT)
library(knitr)
library(pandoc)

#https://mran.revolutionanalytics.com/snapshot/2020-04-25/web/packages/bs4Dash/vignettes/bs4cards.html


dash_list <- readr::read_rds(file = "data/dash_list.rds")
header <- dashboardHeader(title = "@marceelrf")




sidebar <- dashboardSidebar(
  fluidRow(
    img(id="myimg",
        src = "marcelferreira.jpg",
        width = "90%",
        tags$style(
          "#myimg{
          object-fit:cover;
          border-radius:50%;}"
          )
        )
  ),
  fluidRow(
    h2("Marcel Ferreira, PhD",
       id= "titleside",
       tags$style("#titleside{
                  color: #b3f0ff;
                  text-align: center;
       }")),
    hr(),
    p(id= "sidetext2",
      tags$style("#sidetext2{
                 text-align: justify;
                 background-color: 8f8f8f;
                 color: #ff8080;
                 padding-right: 5%;
                 padding-left: 5%;
      }"),
      "Data Scientist | R | Shiny | Python | Researcher | Biomaterials | Bioinformatics | 3D Bioprinting"),
    hr(),
    p(id= "sidetext",
      tags$style("#sidetext{
                 text-align: justify;
                 background-color: 8f8f8f;
                 color: #b3f0ff;
                 padding-right: 5%;
                 padding-left: 5%;
      }"),
      "Medical physicist and PhD in Biotechnology.\n
      Works with big omics data for bone biomaterials analysis."),
    hr()
  )
)

body <- dashboardBody(
  useShinyjs(),
  tabsetPanel(
    selected = "Scientific Profile",
    tabPanel(title = "CV",
             includeMarkdown(path = "md_files/CV.md"),
             actionButton("downloadBtn", "Download PDF")),
    tabPanel(title = "Scientific Profile",
             fluidRow(
               bs4ValueBox(value = dash_list$nPub,width = 4,
                           subtitle = "Publications",
                           color = "lightblue",
                           icon = icon("folder-open",lib = "glyphicon")
               ),
               bs4ValueBox(value = dash_list$nCites,width = 4,
                           subtitle = "Citations",
                           color = "lightblue",
                           icon = icon("signal",lib = "glyphicon")
               ),
               bs4ValueBox(value = dash_list$hIndex,width = 4,
                           subtitle = "h-index",
                           color = "lightblue",
                           icon = icon("flash",lib = "glyphicon")
               )
             ),
             fluidRow(
               bs4Card(plotlyOutput("pCitesPerYear"),
                       title = "Cites per year - Marcel Ferreira",
                       width = 6),
               bs4Card(wordcloud2::wordcloud2Output("wc"),
                       title = "Wordcloud",
                       width = 6)
             ),
             fluidRow(
               bs4Card(
                 dataTableOutput("table"),
                 title = "selected publications",
                 width = 12)
               )
             ),
    tabPanel("Presentations",
             includeMarkdown(path = "md_files/Press.md")),
    tabPanel("Shiny apps",
             includeMarkdown(path = "md_files/ShinyList.md")),
    tabPanel("Gallery"
      )
  )
)

footer <- dashboardFooter(left = "Marcel Ferreira",
                          right = "2023")

ui <- bs4DashPage(header = header,
                  sidebar = sidebar,
                  body = body,
                  footer = footer,
                  title = "@marceelrf")

server = function(input, output) {
  output$pCitesPerYear <- renderPlotly(
    dash_list$tidycites %>%
      plot_ly(x= ~year, y= ~cites,
              type = "scatter",
              mode = "lines+markers",
              text = ~paste("Year: ", year,"\n Cites:",cites),
              marker = list(color = "#800000",
                            size = 15
              ),
              line = list(
                color = "#800000",
                size = 5
              )
      ) %>%
      layout(
        xaxis = list(
          title = "Year",
          dtick = 1,
          tick0 = 2015,
          tickmode = "linear"
        ),
        yaxis = list(
          title = "Cites",
          dtick = 20,
          tick0 = 0,
          tickmode = "linear"
        )
      )
  )
  output$wc <- wordcloud2::renderWordcloud2(
    wordcloud2(
      slice_max(dash_list$freq_tokens,order_by = n,n = 100,with_ties = F),
               size = .4,
               minRotation = -pi/2,
               maxRotation = -pi/2,
      #color ="random-light",backgroundColor = "grey50"
      ))

  my_table <- reactive({
    datatable(
      dash_list$tableSug,
      options = list(
        columnDefs = list(
          list(
            targets = 1,
            render = JS(
              "function(data, type, row, meta) {",
              "  if (type === 'display') {",
              "    return '<b><i>' + data + '</i></b>';",
              "  } else {",
              "    return data;",
              "  }",
              "}"
            )
          ),
          list(
            targets = 2,
            render = JS(
              "function(data, type, row, meta) {",
              "  if (type === 'display') {",
              "    return '<a href=\"' + data + '\">' + row[2] + '</a>';",
              "  } else {",
              "    return data;",
              "  }",
              "}"
            )
          )
        ),
        rownames = FALSE,
        lengthMenu  = FALSE,
        searching = FALSE
      ),
      escape = FALSE
    )
  })
  output$table <- DT::renderDataTable({
    my_table()
  })

  # Function to generate PDF from markdown

  cv <- readLines("md_files/CV.md")  # Path to your CV.md file
  cv_file <- file.path("www", "CV.Rmd")
  writeLines(cv, cv_file)
  pdf_file <- file.path("www", "CV.pdf")
  render(here::here(cv_file),
         output_format = "pdf_document",
         output_file = here::here(pdf_file))


  # Trigger download when the button is clicked
  observeEvent(input$downloadBtn, {
    pdf_file <- file.path("www", "CV.pdf")
    if (file.exists(pdf_file)) {
      output$downloadFile <- downloadHandler(
        filename = "CV.pdf",
        content = function(file) {
          file.copy(here::here(pdf_file), file)
        }
      )
    }
  })

}

shinyApp(ui = ui,server = server)
