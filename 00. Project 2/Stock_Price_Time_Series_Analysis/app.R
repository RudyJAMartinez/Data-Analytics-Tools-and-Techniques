library(shiny)
library(quantmod)

# Define UI for application that draws a histogram
ui = fluidPage(

    # Application title
    titlePanel("Stock Price Time Series Analysis"),

    sidebarLayout(
        sidebarPanel(
            textInput(inputId = "symbol", "Enter Ticker Symbol" ,"SPY"),
            
            dateRangeInput("dates",
                       "Date range",
                       start = "2021-01-01",
                       end = as.character(Sys.Date())),
            
            br(),
            br()),
        mainPanel(plotOutput(outputId = "results"))
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

        chartSeries(dataInput(), name = input$symbol, theme = chartTheme("black"),
                    type = "matchsticks", TA = "addSMA()")
        addVo()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
