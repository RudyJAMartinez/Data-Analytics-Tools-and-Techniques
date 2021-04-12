t<-read.csv("./Data/nic-cage.csv", stringsAsFactors = F)
str(t)
t$RottenTomatoes<-as.numeric(t$RottenTomatoes)

save(t, file="./Data/nic-cage.RData")
load(url("https://raw.githubusercontent.com/mattdemography/STA_6233_Spring2021/master/Data/nic-cage.RData"))
