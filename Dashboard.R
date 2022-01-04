# libraries ---------------------------------------------------------------
library(tidyverse)
library(shinydashboard)
library(shiny)


# Functions(?) ------------------------------------------------------------



# UI ----------------------------------------------------------------------
header <- dashboardHeader(title = "LaBIO - IBB/UNESP")

# Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(icon = NULL,
      fluidRow(
        img(src = "labio.jpg",
            width="100%")
        )
      ),
    menuItem(
      fluidRow(
        column(width = 2,
               h4("Bioassays and cellular dynamics lab"))
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
