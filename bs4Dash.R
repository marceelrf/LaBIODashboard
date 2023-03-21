library(tidyverse)
library(shinydashboard)
library(shiny)
library(bs4Dash)
library(wordcloud2)
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
      Works on the development of tools for bone biomaterials analysis."),
    hr(),
    h4("Follow me")
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
    bs4Card(plotOutput("ggplot"),
      title = "Cites per year - ggplot",
      width = 6),
    bs4Card(wordcloud2::wordcloud2Output("wc"),
            title = "Wordcloud",
            width = 6)
  ),
  fluidRow(
    h1("selected publications - TABELA")
  )
)

footer <- dashboardFooter(left = "Marcel Ferreira",
                          right = "2023")

ui <- bs4DashPage(header = header,
                  sidebar = sidebar,
                  body = body,
                  footer = footer,
                  title = "test")

server = function(input, output) {
  output$ggplot <- renderPlot(p_cites_per_year)
  output$wc <- wordcloud2::renderWordcloud2(
    wordcloud2(
      slice_max(freq_tokens,order_by = n,n = 100,with_ties = F),
               size = .4,
               minRotation = -pi/2,
               maxRotation = -pi/2,
      #color ="random-light",backgroundColor = "grey50"
      ))
}

shinyApp(ui = ui,server = server)
