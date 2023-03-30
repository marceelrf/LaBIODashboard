library(tidyverse)
library(shinydashboard)
library(shiny)
library(bs4Dash)
library(wordcloud2)
library(plotly)
library(DT)
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
    p(id= "sidetext",
      tags$style("#sidetext{
                 text-align: justify;
                 background-color: 8f8f8f;
                 color: #b3f0ff;
      }"),
      "Medical physicist and PhD in Biotechnology.\n
      Works with big omics data for bone biomaterials analysis."),
    hr()
  )
)

body <- dashboardBody(
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
}

shinyApp(ui = ui,server = server)
