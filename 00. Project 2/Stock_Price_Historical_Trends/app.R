library(shiny)
library(quantmod)
library(shinythemes)

# Define UI for application that draws a histogram
ui = fluidPage(
    
    theme = shinytheme("journal"),
    
    # Application title
    titlePanel("Historical Trends",),
    
    sidebarLayout(
        sidebarPanel(
            textInput(inputId = "symbol", h4("Enter Ticker Symbol"),"SPY"),
            
            radioButtons(inputId = "metric", label = h4("Metric"), 
                         choices = list("addSMA()" = 1, 
                                        "addEMA()" = 2, 
                                        "addWMA()" = 3, 
                                        "addDEMA()" = 4), 
                         selected = 1),
            
            dateRangeInput("dates",
                           "Date range",
                           start = "2021-01-01",
                           end = as.character(Sys.Date())),
            
            width = 4,
            
            br(),
            br()),
        mainPanel(plotOutput(outputId = "results"), width = 8),
        position = c("left", "right")
    )
)

# Define server logic 
server <- function(input, output) {
    
    dataInput = reactive({
        getSymbols(input$symbol, src = "yahoo",
                   from = input$dates[1],
                   to = input$dates[2],
                   auto.assign = FALSE)
    })
    
    output$results = renderPlot({
        
        chartSeries(dataInput(), name = input$symbol, theme = chartTheme("white"),
                    type = "candlesticks")
        addRSI(n=14, maType="EMA")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
