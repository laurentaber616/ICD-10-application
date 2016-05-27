library(shiny)
library(RNeo4j)

# Build UI.
shinyUI(fluidPage(
  titlePanel("ICD 10 Code Search"),
  sidebarLayout(
    sidebarPanel(
      h3("Search by Location and Category"),
      strong("Please select a location and category below:"),
      br(),
      
      uiOutput("Box1"),
      
      uiOutput("Box2"),
      br(),
      
      h3("Search by Keyword"),
      uiOutput("Box3")
  
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Code List",tableOutput("codes")),
        tabPanel("Statistics",tableOutput("statistics"))
        )
    )
   
      
    
  
  )
))
