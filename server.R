library(shiny)
library(RNeo4j)


# Connect to the Neo4j DB.
graph = startGraph("http://localhost:7474/db/data/")


df = cypher(graph, "match n where n.valid = 0 return n.long AS categories, n.location AS location ")




shinyServer(function(input, output) {
  
  output$Box1 = renderUI(selectInput("location","Select a location:",c("All",df$location,"pick one"),"pick one"))
  
  
  output$Box2 = renderUI(
    if (is.null(input$location) || input$location == "pick one"){return()
    }else if (input$location == "All"){
      selectizeInput("categories", 
                     "Select 1 or more categories", 
                     choices = c(df$categories),
                     multiple = TRUE)
    }
    else selectizeInput("categories", 
                      "Select 1 or more categories", 
                      choices = c(df$categories[which(df$location == input$location)]),
                      multiple = TRUE
                      ),
    
  )
  

  output$Box3 = renderUI(
    textInput("search","Keyword", "")
    )
  
  
  
  output$codes <- renderTable({
   #if selections are null
    if(is.null(input$location) || is.null(input$categories)  ){
      if (input$search==""){return()
      }else {
        searchfield=paste("(?i).*",input$search, ".*", sep="")
        df = cypher(graph, "match (m:Procedure)
                  where m.valid = 1 and m.long =~ {search}
                  return m.code AS Code, m.long AS Description",
                    categories= input$categories, search= searchfield)
        
        return(df)
      } 
      
    } 
    #if selcetions are "pick one"
    else if (input$location == "pick one" || input$categories == "pick one" ){
      if (input$search==""){return()
      }else {
        searchfield=paste("(?i).*",input$search, ".*", sep="")
        df = cypher(graph, "match (m:Procedure)
                  where and m.valid = 1 and m.long =~ {search}
                  return m.code AS Code, m.long AS Description",
                    categories= input$categories, search= searchfield)
        
        return(df)
      }
      
      
    } 
    #if selections are not null but search is
    else if (input$search=="")   {
      df = cypher(graph, "match (n:Procedure) - [r:parent_of] -> (m:Procedure)
                  where n.long in {categories} and m.valid = 1
                  return m.code AS Code, m.long AS Description",
                  categories= input$categories)
      
         return(df)}
    # if nothing is null
    else {
      searchfield=paste("(?i).*",input$search, ".*", sep="")
      df = cypher(graph, "match (n:Procedure) - [r:parent_of] -> (m:Procedure)
                  where n.long in {categories} and m.valid = 1 and m.long =~ {search}
                  return m.code AS Code, m.long AS Description",
                  categories= input$categories, search= searchfield)
      
      return(df)
    }
  })
  
 
  #statistics output
  output$statistics <- renderTable(
    digits = 0,
    {
    #if selections are null
    if(is.null(input$location) || is.null(input$categories)  ){
      if (input$search==""){return()
      }else {
        searchfield=paste("(?i).*",input$search, ".*", sep="")
        df = cypher(graph, "match (n:Procedure) - [r:parent_of] ->(m:Procedure)
                    where m.valid = 1 and m.long =~ {search}
                    return n.long AS Category, count(*) AS Count
                    order by count(*) desc",
                    categories= input$categories, search= searchfield)
        
        return(df)
      } 
      
    } 
    #if selcetions are "pick one"
    else if (input$location == "pick one" || input$categories == "pick one" ){
      if (input$search==""){return()
      }else {
        searchfield=paste("(?i).*",input$search, ".*", sep="")
        df = cypher(graph, "match (n:Procedure) - [r:parent_of] ->(m:Procedure)
                    where and m.valid = 1 and m.long =~ {search}
                    return n.long AS Category, count(*) AS Count
                    order by count(*) desc",
                    categories= input$categories, search= searchfield)
        
        return(df)
      }
      
      
    } 
    #if selections are not null but search is
    else if (input$search=="")   {
      df = cypher(graph, "match (n:Procedure) - [r:parent_of] -> (m:Procedure)
                  where n.long in {categories} and m.valid = 1
                  return n.long AS Category, count(*) AS Count
                  order by count(*) desc",
                  categories= input$categories)
      
      return(df)}
    # if nothing is null
    else {
      searchfield=paste("(?i).*",input$search, ".*", sep="")
      df = cypher(graph, "match (n:Procedure) - [r:parent_of] -> (m:Procedure)
                  where n.long in {categories} and m.valid = 1 and m.long =~ {search}
                  return n.long AS Category, count(*) AS Count
                  order by count(*) desc",
                  categories= input$categories, search= searchfield)
      
      return(df)
    }
  })
  
}
)
