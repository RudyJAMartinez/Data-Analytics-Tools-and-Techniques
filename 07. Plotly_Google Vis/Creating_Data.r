library(googleVis)
library(tidyr)
library(dplyr)
library(scales)

#Bring in Data
all_cohorts<-read.csv("https://raw.githubusercontent.com/mattdemography/STA_6233_Spring2021/master/Data/all_cohorts.csv")
count<-read.csv("https://raw.githubusercontent.com/mattdemography/STA_6233_Spring2021/master/Data/cohort_counts.csv")

#Find All Possible Transitions
caps<-names(all_cohorts[1:13])
caps_l<-names(all_cohorts[2:14]) #Lag Previous Variable
j<-as.data.frame(table(all_cohorts$trans))

#Label these transitions
  #Create list to change to
  cap_num<-c("13", "15", "19", "21", "25", "31", "33", "37", "39", "42", "46", "47", "48", "49", "51", "73", "3", "4", "5", "6", "7")
  cap_name<-c("Non-Exempt ->", "Part-Time ->",  "Ex-Employee ->", "Unknown ->",  "Temp-Employee ->", "Temp-Employee ->", "Intern ->", "Intern ->", "Unknown ->", 
              "Deceased-Employee ->", "Ex-Employee ->", "Outsourced ->", "Temp ->", "Ex-Temp ->", "Business-Partner ->", "Deceased-Temp ->", 
              "Full-Time ->", "Unknown ->", "Ex-Intern ->", "Family ->", "Ex-Employee ->")
#Create Loop
  j$name<-j$Var1 #Create Copy
  for(s in 1:length(cap_num)){
    j$name<-gsub(cap_num[s], cap_name[s], j$name) #Use Regular Expression to take what is in cap_num and put cap_name instead
  }
  #Eliminate all same-state non-transition months
  j$unique_name<-vapply(strsplit(j$name, " "), function(x) paste(unique(x), collapse = " "), character(1L)) 
  
#Get All Unique Transitions overall and how often it occurs
  t<-aggregate(j$Freq, by=list(j$unique_name), FUN=sum)
  t<-plyr::rename(t, c("Group.1"="Transition Type", "x"="Frequency"))
  t<-t[order(-t$Frequency),]

#Add a total Column to count
  count$Total<-rowSums(count[2:13])

#Create a Survival Format
  c<-count$Total
  #Create a How many part-time employees remain after end of month
  for(i in 1:1){
    eval(parse(text=paste0('count$ms_', i-1, '<-c')))
    for(k in 1:12){
      eval(parse(text=paste0('count$ms_', k, '<-(count$ms_', k-1, ' - count$Month_', k, ')')))
    }
  }
  #What Percent of total that became full-time at end of month
  for(k in 1:12){
    eval(parse(text=paste0('count$Percent_Left_in_Month_', k,'<-round(as.numeric(count$Month_', k,'/count$Total)*100,2)')))
  }
  #What percent remain as non full-time at end of month
  for(k in 1:12){
    eval(parse(text=paste0('count$Percent_Remain_in_Month_', k,'<-round(as.numeric(count$ms_', k-1,'/count$Total)*100,2)')))
  }

#Now Make this data long
  tout<- count[2:15] %>% gather(Month_Code, No_Longer_Employee, Month_1:Month_12)
  tout_p<- count[29:40] %>% gather(Month_Code, Percent_No_Longer_Employee, Percent_Left_in_Month_1:Percent_Left_in_Month_12)
  survive<-count[14:27] %>% gather(time_survive, Still_Employee, ms_0:ms_11)
  survive_p<-count[41:52] %>% gather(time_survive, Percent_Still_Employee, Percent_Remain_in_Month_1:Percent_Remain_in_Month_12)
  count_l<-cbind(tout[c(1:2,4)], tout_p[2], survive[4], survive_p[2])
  count_l$Month<-with(count_l, ave(as.character(count_l$cohort), as.character(count_l$cohort), FUN=seq_along)) %>% as.numeric()
  count_l$Month<-count_l$Month + 100 #Adding 100 so that it remains in order as 1, 11, 12, 2 will be order without this

  all_sum1<-mean(count$Total)
  all_sum2<-mean(all_cohorts$count)
  tot_cnt<-sum(count$Total)
  
  #Reorder Factor Levels
  count$fl<-ifelse(count$cohort=="17-Jan", 1, ifelse(count$cohort=="17-Feb", 2, ifelse(count$cohort=="17-Mar", 3,
    ifelse(count$cohort=="17-Apr", 4, ifelse(count$cohort=="17-May", 5, ifelse(count$cohort=="17-Jun", 6, ifelse(count$cohort=="17-Jul", 7,
    ifelse(count$cohort=="17-Aug", 8, ifelse(count$cohort=="17-Sep", 9, ifelse(count$cohort=="17-Oct", 10, ifelse(count$cohort=="17-Nov", 11,
    ifelse(count$cohort=="17-Dec", 12, NA))))))))))))
  count$cohort<-factor(count$cohort, levels=count$cohort[order(count$fl)])
  
  count_l$fl<-ifelse(count_l$cohort=="17-Jan", 1, ifelse(count_l$cohort=="17-Feb", 2, ifelse(count_l$cohort=="17-Mar", 3,
    ifelse(count_l$cohort=="17-Apr", 4, ifelse(count_l$cohort=="17-May", 5, ifelse(count_l$cohort=="17-Jun", 6, ifelse(count_l$cohort=="17-Jul", 7,
    ifelse(count_l$cohort=="17-Aug", 8, ifelse(count_l$cohort=="17-Sep", 9, ifelse(count_l$cohort=="17-Oct", 10, ifelse(count_l$cohort=="17-Nov", 11,
    ifelse(count_l$cohort=="17-Dec", 12, NA))))))))))))

  #count_l$cohort<-factor(count_l$cohort, levels=count_l$cohort[order(count_l$fl)])
  
#Create Visualizations  
myStateSettings_time<-'
  {"yZoomedIn":false,"time":"101","sizeOption":"_UNISIZE","orderedByY":false,"yZoomedDataMax":4000,"nonSelectedAlpha":0.4,"orderedByX":true,"iconKeySettings":[],
  "uniColorForNonSelected":false,"yLambda":1,"yAxisOption":"3","xLambda":1,"showTrails":false,"xZoomedDataMax":12,"dimensions":{"iconDimensions":["dim0"]},
  "yZoomedDataMin":0,"iconType":"VBAR","colorOption":"_UNIQUE_COLOR", "duration":{"multiplier":1,"timeUnit":"Y"},"playDuration":15088.88888888889,
  "xAxisOption":"_ALPHABETICAL","xZoomedIn":false,"xZoomedDataMin":0}
  '
m_reg<-gvisMotionChart(count_l[1:132,c(1:4,7)], idvar="cohort", timevar = "Month")
m_time<-gvisMotionChart(count_l[,c(1:2, 5:7)], idvar="cohort", timevar = "Month", options=list(state=myStateSettings_time))
plot(m_reg)  
plot(m_time)

#Grab Only the 6th month
  six<-count_l[61:72,c(1,6)]
  max<-subset(six, six$Percent_Still_Employee==max(six$Percent_Still_Employee))
  min<-subset(six, six$Percent_Still_Employee==min(six$Percent_Still_Employee))

  line_t<-ggplot(data=count_l, aes(x=count_l$Month, y=count_l$Percent_Still_Employee, group=count_l$cohort)) + xlab("Month Number") +
    ylab("Percent Still Employee") +  geom_line(aes(color=count_l$cohort)) + geom_vline(xintercept = 106, linetype="dashed") + theme_light() + 
    scale_color_discrete(name="Legend") + scale_x_continuous(breaks=seq(101, 112,1)) + ggtitle("Percent Employee Remaining After Each Period by Cohort")
  plot(line_t)

  all_sum1<-mean(count$Total)
  bar1<-ggplot(data=count, aes(count$cohort, fill=count$cohort)) + geom_bar(aes(weight=count$Total)) +  
    scale_fill_manual(values=c("17-Apr"="lightcyan3", "17-Aug"="lightcyan4", "17-Dec"="lightcyan3", "17-Feb"="lightcyan4", "17-Jan"="lightcyan3",
                               "17-Jul"="lightcyan4", "17-Jun"="lightcyan3", "17-Mar"="lightcyan4", "17-May"="lightcyan3", "17-Nov"="lightcyan4",
                               "17-Oct"="lightcyan3", "17-Sep"="lightcyan4"), guide=F) + xlab("Cohort") + ylab("Total Employee") + theme_light() + 
    scale_y_continuous(limits=c(0, 3500), oob=rescale_none) + geom_hline(yintercept = all_sum1, linetype="dashed", colour="indianred3") + 
    geom_text(aes(x=count$cohort, y=count$Total, label=count$Total), vjust=-1) + ggtitle("Total Number of Employee as Operators by Cohort") 
  plot(bar1)

#Create new dataset with just the summary statistics
  sum_stats<-all_cohorts[,18:19] %>% group_by(cohort) %>% summarise_each(funs(mean(., na.rm = T), sd(., na.rm=T)))
  sum_stats$fl<-ifelse(sum_stats$cohort=="17-Jan", 1, ifelse(sum_stats$cohort=="17-Feb", 2, ifelse(sum_stats$cohort=="17-Mar", 3,
    ifelse(sum_stats$cohort=="17-Apr", 4, ifelse(sum_stats$cohort=="17-May", 5, ifelse(sum_stats$cohort=="17-Jun", 6, ifelse(sum_stats$cohort=="17-Jul", 7,
    ifelse(sum_stats$cohort=="17-Aug", 8, ifelse(sum_stats$cohort=="17-Sep", 9, ifelse(sum_stats$cohort=="17-Oct", 10, ifelse(sum_stats$cohort=="17-Nov", 11,
    ifelse(sum_stats$cohort=="17-Dec", 12, NA))))))))))))
  sum_stats$cohort<-factor(sum_stats$cohort, levels=sum_stats$cohort[order(sum_stats$fl)])

  all_sum2<-mean(all_cohorts$count)
  bar2<-ggplot(data=sum_stats, aes(sum_stats$cohort, fill=sum_stats$cohort)) + geom_bar(aes(weight=sum_stats$mean)) +  
    scale_fill_manual(values=c("17-Apr"="lightcyan3", "17-Aug"="lightcyan4", "17-Dec"="lightcyan3", "17-Feb"="lightcyan4", "17-Jan"="lightcyan3",
                               "17-Jul"="lightcyan4", "17-Jun"="lightcyan3", "17-Mar"="lightcyan4", "17-May"="lightcyan3", "17-Nov"="lightcyan4",
                               "17-Oct"="lightcyan3", "17-Sep"="lightcyan4"), guide=F) + xlab("Cohort") + ylab("Average Months") + theme_light() + 
    scale_y_continuous(limits=c(8.25,9.25), oob=rescale_none) + geom_hline(yintercept = all_sum2, linetype="dashed", colour="indianred3") + 
    geom_text(aes(x=sum_stats$cohort, y=sum_stats$mean, label=round(sum_stats$mean,2)), vjust=-1) + ggtitle("Average Months Employee Remain by Cohort") 
  plot(bar2)

myTheme<-ttheme_default(
  core=list(fg_params=list(hjust=1, x=1),
            bg_params=list(fill=c("cornflowerblue", "gray92"))),
  colhead=list(fg_params=list(col="white"),
               bg_params=list(fill="mediumpurple"))
)

trans_table<-tableGrob(t[1:15,], rows=NULL, theme=myTheme, vp=NULL)
plot(trans_table)

