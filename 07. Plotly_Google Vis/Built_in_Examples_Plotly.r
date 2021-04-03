install.packages("plotly")
library(plotly)
library(tidyr)
library(dplyr)

#### Line Graph ####
  data("airmiles")
  plot_ly(x = time(airmiles), y = airmiles, mode='lines',type='scatter', height=350)
  
  # Multi-Line Graph
    data("EuStockMarkets")
    
    stocks <- as_tibble(EuStockMarkets) %>%
      gather(index, price) %>%
      mutate(time = rep(time(EuStockMarkets), 4))
    
    plot_ly(x = stocks$time, y = stocks$price, color = stocks$index, type = 'scatter', mode = 'lines')

  # Density Plots
    dens <- with(diamonds, tapply(price, INDEX = cut, density))
    df <- data.frame(
      x = unlist(lapply(dens, "[[", "x")),
      y = unlist(lapply(dens, "[[", "y")),
      cut = rep(names(dens), each = length(dens[[1]]$x))
    )
    
    fig <- plot_ly(df, x = ~x, y = ~y, color = ~cut) 
    fig <- fig %>% add_lines()
    
    fig
  
#### Box Plots ####
  plot_ly(midwest, x = ~percollege, color = ~state, type = "box", height=350, width=800)
    
#### Histogram ####
  plot_ly(x = ~rnorm(50), type = "histogram",height=350, width = 600)
    
  # Overlapping Histograms
    fig <- plot_ly(alpha = 0.6)
    fig <- fig %>% add_histogram(x = ~rnorm(500))
    fig <- fig %>% add_histogram(x = ~rnorm(500) + 1)
    fig <- fig %>% layout(barmode = "overlay")
    
    fig

#### Scatter Plot ####
  plot_ly(data = iris, x = ~Sepal.Length, y = ~Petal.Length)

  #Adding Qualitative Color Scales
  plot_ly(data = iris, x = ~Sepal.Length, y = ~Petal.Length, color = ~Species)

  #Adding Color and Sizing
  plot_ly(diamonds[sample(nrow(diamonds), 1000), ], x = ~carat, y = ~price, color = ~carat, size = ~carat)
  
#### 3D Scatter Plot ####
  mtcars$am[which(mtcars$am == 0)] <- 'Automatic'
  mtcars$am[which(mtcars$am == 1)] <- 'Manual'
  mtcars$am <- as.factor(mtcars$am)
  
  fig <- plot_ly(mtcars, x = ~wt, y = ~hp, z = ~qsec, color = ~am, colors = c('#BF382A', '#0C4B8E'))
  fig <- fig %>% add_markers()
  fig <- fig %>% layout(scene = list(xaxis = list(title = 'Weight'),
                                     yaxis = list(title = 'Gross horsepower'),
                                     zaxis = list(title = '1/4 mile time')))
  
  fig

  plot_ly(ggplot2::diamonds, y = ~price, color = ~cut, type = "box")
  
#### 3D Surface Plot ####
  plot_ly(z = ~volcano) %>% add_surface()
  
#### Maps ####
  df <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv")
  df$hover <- with(df, paste(state, '<br>', "Beef", beef, "Dairy", dairy, "<br>",
                             "Fruits", total.fruits, "Veggies", total.veggies,
                             "<br>", "Wheat", wheat, "Corn", corn))
  # give state boundaries a white border
  l <- list(color = toRGB("white"), width = 2)
  # specify some map projection/options
  g <- list(
    scope = 'usa',
    projection = list(type = 'albers usa'),
    showlakes = TRUE,
    lakecolor = toRGB('white')
  )
  
  fig <- plot_geo(df, locationmode = 'USA-states')
  fig <- fig %>% add_trace(
    z = ~total.exports, text = ~hover, locations = ~code,
    color = ~total.exports, colors = 'Purples'
  )
  fig <- fig %>% colorbar(title = "Millions USD")
  fig <- fig %>% layout(
    title = '2011 US Agriculture Exports by State<br>(Hover for breakdown)',
    geo = g
  )
  
  fig
  
  # A Quick Note On Projections #
  #https://thetruesize.com/#?borders=1~!MTc3OTQ2OTY.MTY2MTkyOA*MzYwMDAwMDA(MA~!CONTIGUOUS_US*NzI0NjI0Nw.MTk4ODYxMDg(MTc1)MA~!IN*NTI2NDA1MQ.Nzg2MzQyMQ)MQ~!CN*OTkyMTY5Nw.NzMxNDcwNQ(MjI1)Mg~!GL*Mzk1NTI.MTk5NzE3NTU)Mw
  #https://www.youtube.com/watch?v=vVX-PrBRtTY
  
