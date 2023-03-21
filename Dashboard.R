# libraries ---------------------------------------------------------------
library(tidyverse)
library(shinydashboard)
library(shiny)
library(bs4Dash)
bs4DashGallery()

# Functions(?) ------------------------------------------------------------



# UI ----------------------------------------------------------------------
header <- dashboardHeader(title = "@marceelrf")

# Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    # div(
    # fluidRow(
    #   img(src = "marcelferreira.jpg",
    #       width="90%",
    #       align = "center"))
    # ),
    div(includeHTML(path = "about.html")),
    div(
      fluidRow(
        column(width = 2,
               h5("Bioassays and cellular dynamics lab",align = "center"))
        )
      ),
    # menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    # menuItem("Widgets", icon = icon("th"), tabName = "widgets",
    #          badgeLabel = "new", badgeColor = "orange")
  )
)

body <- dashboardBody(

  fluidRow(
    #box(plotOutput("p1"),width = 5,height = 5)
    bs4ValueBoxOutput("hindex")

    )
)

ui <- dashboardPage(header = header,
                    sidebar = sidebar,
                    body = body,
                    title = "marceelrf",
                    skin = "blue")
# Server ------------------------------------------------------------------
server <- function(input, output){
  output$p1 <- renderPlot({
    p_cites_per_year
    })

  output$hindex <- renderValueBox(
    bs4ValueBox(value = 10,
                subtitle = "h-index",
                color = "navy"
    )
  )

}



# Run App -----------------------------------------------------------------

shiny::shinyApp(ui = ui,server = server)
