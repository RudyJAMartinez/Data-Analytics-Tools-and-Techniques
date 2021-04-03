install.packages("googleVis")
library(googleVis)
#data(Fruits)
#M <- gvisMotionChart(Fruits, idvar="Fruit", timevar="Date")
#plot(M)

#### Line Graph ####
  df=data.frame(country=c("US", "GB", "BR"), 
                val1=c(10,13,14), 
                val2=c(23,12,32))
  Line <- gvisLineChart(df)
  plot(Line)

#### Bar Graph ####
  Bar <- gvisBarChart(df)
  plot(Bar)

#### Scatter Plot ####
  Scatter <- gvisScatterChart(women, 
                            options=list(
                              legend="none",
                              lineWidth=2, pointSize=0,
                              title="Women", vAxis="{title:'weight (lbs)'}",
                              hAxis="{title:'height (in)'}", 
                              width=300, height=300))
  plot(Scatter)

#### BoxPlot ####
  Candle <- gvisCandlestickChart(OpenClose, 
                                 options=list(legend='none'))
  plot(Candle)
  
#### Pie Chart ####
  Pie <- gvisPieChart(CityPopularity)
  plot(Pie)
  
#### Tables ####
  Table <- gvisTable(Stock)
  plot(Table)

#### Adding Edit Option ####
  edit_graph <-  gvisLineChart(df, "country", c("val1","val2"),
                          options=list(gvis.editor="Edit me!"))
  plot(edit_graph)
  

#### Show How to Customize Line Charts ####
  Line3 <-  gvisLineChart(df, xvar="country", yvar=c("val1","val2"),
                          options=list(
                            title="Hello World",
                            titleTextStyle="{color:'red', 
                                           fontName:'Courier', 
                                           fontSize:16}",                         
                            backgroundColor="#D3D3D3",                          
                            vAxis="{gridlines:{color:'red', count:3}}",
                            hAxis="{title:'Country', titleTextStyle:{color:'blue'}}",
                            series="[{color:'green', targetAxisIndex: 0}, 
                                   {color: 'orange',targetAxisIndex:1}]",
                            vAxes="[{title:'val1'}, {title:'val2'}]",
                            legend="bottom",
                            curveType="function",
                            width=500,
                            height=300                         
                          ))
  plot(Line3)

#### Mapping ####
  Geo=gvisGeoChart(Exports, locationvar="Country", 
                   colorvar="Profit",
                   options=list(projection="kavrayskiy-vii"))
  plot(Geo)
  
  # A Quick Note On Projections #
  #https://thetruesize.com/#?borders=1~!MTc3OTQ2OTY.MTY2MTkyOA*MzYwMDAwMDA(MA~!CONTIGUOUS_US*NzI0NjI0Nw.MTk4ODYxMDg(MTc1)MA~!IN*NTI2NDA1MQ.Nzg2MzQyMQ)MQ~!CN*OTkyMTY5Nw.NzMxNDcwNQ(MjI1)Mg~!GL*Mzk1NTI.MTk5NzE3NTU)Mw
  #https://www.youtube.com/watch?v=vVX-PrBRtTY
  
#### Merging Charts ####
  G <- gvisGeoChart(Exports, "Country", "Profit", 
                    options=list(width=300, height=300))
  T <- gvisTable(Exports, 
                 options=list(width=220, height=300))
  
  GT <- gvisMerge(G,T, horizontal=TRUE) 
  plot(GT)
  