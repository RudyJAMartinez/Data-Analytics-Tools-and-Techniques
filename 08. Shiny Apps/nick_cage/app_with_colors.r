#Load the Library
library(shiny)
library(ggplot2)
load(url("https://raw.githubusercontent.com/mattdemography/STA_6233/master/Data/nic-cage.RData"))

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Nicolas Cage \"American Hero\""),
    
    # Sidebar layout
    sidebarLayout(
        #Inputs: Select which inputs from the data we want to display
        sidebarPanel(
            #Select variable for y-axis
            selectInput(inputId = "y", 
                        label = "Y-axis:",
                        choices = c("RottenTomatoes"), 
                        selected = "Rating"),
            #Select X-axix variables
            selectInput(inputId = "x", 
                        label = "X-axis:",
                        choices = c("Voice", "Year"), 
                        selected = "Year"),
            
            # Select Colors
            selectInput(inputId = "thecolors", 
                        label = "Choose Your Point Color",
                        choices = c("red", "green", "blue", "yellow", "black"), 
                        selected = "black"),
        ),
        
        #Output: Type of plot
        mainPanel(
            plotOutput(outputId = "FreqTab") #Any name can go where "FreqTab" is, but be sure to keep it consistent with name in output$FreqTab in the server section
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$FreqTab <- renderPlot({
        # draw the histogram with the specified number of bins
        ggplot(t, aes_string(x=input$x, y=input$y)) + geom_point(colour=input$thecolors) #Notice the difference between the ggplots
    })
}

# Run the application 
shinyApp(ui = ui, server = server)