# libraries ---------------------------------------------------------------
library(tidyverse)
library(shinydashboard)
library(shiny)


# Functions(?) ------------------------------------------------------------



# UI ----------------------------------------------------------------------
header <- dashboardHeader(title = "LaBIO - IBB/UNESP")

# Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(div(
    fluidRow(
      img(src = "labio.jpg",
          width="90%",
          align = "center"))
    ),
    div(
      fluidRow(
        column(width = 2,
               h5("Bioassays and cellular dynamics lab",align = "center"))
        )
      ),
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Widgets", icon = icon("th"), tabName = "widgets",
             badgeLabel = "new", badgeColor = "orange")
  )
)

body <- dashboardBody()

ui <- dashboardPage(header = header,
                    sidebar = sidebar,
                    body = body,
                    title = "LaBIO",
                    skin = "blue")
# Server ------------------------------------------------------------------
server <- function(input, output){

}



# Run App -----------------------------------------------------------------

shiny::shinyApp(ui = ui,server = server)
