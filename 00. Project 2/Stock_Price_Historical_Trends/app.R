library(shiny)
library(quantmod)
library(shinythemes)

# Define UI for application that draws a histogram
ui = fluidPage(
    
    theme = shinytheme("journal"),
    
    # Application title
    titlePanel("Stock Evaluation Tool",),
    
    sidebarLayout(
        sidebarPanel(
            textInput(inputId = "symbol", h4("Enter Ticker Symbol"),"SPY"),
            
            dateRangeInput("dates",
                           "Date range",
                           start = "2021-01-01",
                           end = as.character(Sys.Date())),
            
            p(strong("Technical Analysis")),
            checkboxInput("ta_vol", label = "volume"),
            checkboxInput("ta_sma", label = "Simple Moving Average"),
            checkboxInput("ta_ema", label = "Exponential Moving Average"),
            checkboxInput("ta_wma", label = "Weighted Moving Average"),
            checkboxInput("ta_bb", label = "Bolinger Bands"),
            checkboxInput("ta_momentum", label = "Momentum"),
            
            width = 4,
            
            br(),
            actionButton("chart_act", "Add Technical Analysis"),
            
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
    
    TAInput = reactive({
        if (input$chart_act == 0)
            return("NULL")
        
        tas = isolate({c(input$ta_vol, input$ta_sma, input$ta_ema, input$ta_wma,
                         input$ta_bb, input$ta_momentum)})
        
        funcs = c(addVo(), addSMA(), addEMA(), addWMA(), addBBands(), addMomentum())
        
        if (any(tas)) funcs [tas]
        else "NULL"
    })
    
    output$results = renderPlot({
        chartSeries(dataInput(), name = input$symbol, theme = chartTheme("white"),
                    type = "candlesticks", TA = TAInput())
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
