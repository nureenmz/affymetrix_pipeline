# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#    http://shiny.rstudio.com/
#
# Code adapted from class code provided in 
# Functional Genomic Technologies 2022 
# by Simon Tomlinson

library(shiny)
library(SummarizedExperiment)
library(org.Hs.eg.db)
library(pheatmap)
library(shinyjs)

#load the example data
       load("expression.Rdata")
       load("experiment.Rdata")

	#Turn off the RStudio graphics
	#graphics.off()

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("GSE49448: Heatmap of Top 50 differential gene expression"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("font_row",
                        "Font size row:",
                        min = 6,
                        max = 14,
                        value = 10),
            sliderInput("font_col",
                        "Font size col:",
                        min = 6,
                        max = 14,
                        value = 10),
            # "select" is the input slot used to access the value
            selectInput("select", "Select annotation", choices=c("none",colnames(experiment)), 
                        selected = NULL, multiple = T, selectize = TRUE),
            checkboxInput("srownames", "Show Row Names", FALSE),
            checkboxInput("logtansform", "Log transform values", FALSE),
            radioButtons("norm", "Scale by", choices=c("none","row","column"))
            
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot", height="800")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

    output$distPlot <- renderPlot(
        # First do the expression that generates the plot
        {
        if(input$logtansform){
            expression <- log2(expression + 1)
        }
       
       if(is.null(input$select)){
           mysel<-NULL
       }else if(input$select[1]=="none"){
           mysel<-NULL
       }else if(length(input$select)==1){
           #if the data frame has one column it converts to a factor
           #force the type to be a data frame and restore row and column names
           mysel <-as.data.frame(experiment[,input$select[1]])
           rownames(mysel) <-rownames(experiment)
           colnames(mysel) <-input$select[1]
       }else{
           mysel<-experiment[,input$select]
       }
        
       pheatmap(expression,
                fontsize_row = input$font_row,
                fontsize_col = input$font_col,
                show_rownames = input$srownames,
                scale = input$norm,
                annotation_col = mysel)
    }, alt="Heatmap of top 50 expressed genes", execOnResize = F)
    
    observeEvent(input$refresh, {
        session$invalidate
    })
        

}

# Run the application 
shinyApp(ui = ui, server = server)