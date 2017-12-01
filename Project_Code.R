#Title: BST 260 Final Project
#Authors: Kara Higgins & Ray An

#Packages
library(tidyverse)
library(lubridate)
library(stringr)
library(ggplot2)
library(ggthemes)
library(ggrepel)
library(dslabs)
ds_theme_set(new="theme_classic")

#Import data
#Currently using 13NOV2017 freeze
data_location <- "C:/Users/kara.THETA_HQ/Documents/Harvard/Classes/Fall 2017/BST 260 Intro to Data Science/Final Project/Data/FREEZE_13NOV2017.csv"

data <- read.csv(data_location, stringsAsFactors = F)



data_location <- "~/Desktop/R programming/uberlyft260final/FREEZE_13NOV2017.csv"
data <- read.csv(data_location, stringsAsFactors = F)

#STEP 1
#Get data in correct format - specs are as follows: RAY will send to Kara by Sunday
#   DATE: Date of request. Format=date (need to specify further based on R formats avail.)
#   DAY_OF_WK: Day of week of request. Format=factor w/ 5 levels
#   REQUEST_DATETIME: Date and time combined. Format=R date
#   TIME: Time of request, calculated as hours/min since start of the day. Format=R time
#   SERVICE: Uber/Lyft. Format=factor w/ 2 levels
#   COST: Cost of ride. Format=numeric double
#   WAIT_TIME: Estimated wait time. Format=numeric
#   ARRIVAL_TIME: Estimated time of arrival. Format=R time (specify further)
#   ARRIVAL_DATETIME: Combined estimated date and time of arrival. Format=R date time.
#   TOTAL_DURATION: Estimated duration incl. wait time. Format=numeric
#   COLLECTOR: Kara/Ray. Format=factor w/ 2 levels
#   AM_PM: AM/PM request time. Format=Factor w/ 2 levels, need to derive\
#   COST_PER_MIN: Cost in dollars per minute of estimated duration. Format=numeric
#   TIME_FROM_MID: Time from midpoint of rush hour (midpoint=9am morning, 6pm evening)

data2 <- data %>% mutate(DATE=as.Date(DATE, format="%m/%d/%Y"),
                         DAY_OF_WK=factor(DAY_OF_WK, levels=c("Monday", "Tuesday", "Wednesday","Thursday","Friday")),
                         DATETIME=as.POSIXct(paste(DATE,TIME),format="%Y-%m-%d %H:%M"),
                         TIME=DATETIME-as.POSIXct(paste(DATE,"00:00:00"), format="%Y-%m-%d %H:%M"),
                         SERVICE=as.factor(SERVICE),
                         ARRIVAL_DATETIME=as.POSIXct(paste(DATE,ARRIVAL_TIME),format="%Y-%m-%d %H:%M"),
                         ARRIVAL_TIME=ARRIVAL_DATETIME-as.POSIXct(paste(DATE,"00:00:00"), format="%Y-%m-%d %H:%M"),
                         COLLECTOR=as.factor(COLLECTOR),
                         AM_PM=as.factor(ifelse(TIME>8 & TIME<10, "AM", "PM")),
                         COST_PER_MIN=COST/as.numeric(TOTAL_DURATION),
                         TIME_FROM_MID=ifelse(AM_PM=="AM",TIME-9, TIME-18)
                           )
#Subset data into AM/PM for stratified analyses
data2_AM <- data2 %>% filter(AM_PM=="AM")
data2_PM <- data2 %>% filter(AM_PM=="PM")

#####UNIVARIATE ANALYSES

#Univariate statistics
summary(data2)

#Variables to get stats on: TIME, COST, WAIT_TIME, TOTAL_DURATION, COST_PER_MIN
p <- data2 %>% ggplot()
##Ride request time distribution - graph shows all-day
png(filename="Plots/ridereq_distr.png")
p + geom_histogram(aes(as.numeric(TIME),..density..),breaks=seq(8,19,.5),color="black") +
  geom_vline(xintercept=c(8,10,17,19), lty=2) +
  geom_label(aes(label="Morning Rush", x=9, y=.6))+
  geom_label(aes(label="Evening Rush", x=18, y=.6))+
  ggtitle("Distribution of Ride Request Time (24 hr clock)")
dev.off()

##Ride request time distribution BY COLLECTOR - graph shows all-day
p + geom_histogram(aes(as.numeric(TIME),..density..),breaks=seq(8,19,.5),color="black") +
  geom_vline(xintercept=c(8,10,17,19), lty=2) +
  geom_label(aes(label="Morning Rush", x=9, y=.6))+
  geom_label(aes(label="Evening Rush", x=18, y=.6))+
  ggtitle("Distribution of Ride Request Time (24 hr clock)") +
  facet_wrap(~COLLECTOR, dir="v")

#Ride cost - histogram
p + geom_histogram(aes(COST,..density.., fill=SERVICE), color="black", binwidth = 2) +
  facet_grid(SERVICE~AM_PM) +
  ggtitle("Distribution of Cost by Service and AM/PM Rush")+
  theme(legend.position = "none")

#Ride cost - boxplot
# Calculate medians to label plot
p_med_cost <- data2 %>% group_by(SERVICE, AM_PM) %>% summarise(med_cost=median(COST))
# Make plot
p + geom_boxplot(aes(SERVICE, COST, fill=SERVICE)) +
  geom_text(data = p_med_cost, aes(x = SERVICE, y = med_cost, label = med_cost), size = 3, vjust = -1)+
  facet_wrap(~AM_PM) +
  ggtitle("Distribution of Total Cost by Service and AM/PM Rush")+
  theme(legend.position = "none")

#Cost/min - histogram
p + geom_histogram(aes(COST_PER_MIN,..density.., fill=SERVICE), color="black", binwidth=.1) +
  facet_grid(SERVICE~AM_PM) +
  ggtitle("Distribution of Cost/Min by Service and AM/PM Rush")+
  theme(legend.position = "none")

#Cost/min - box plot
# Calculate medians to label plot
p_med_costmin <- data2 %>% group_by(SERVICE, AM_PM) %>% summarise(med_costmin=median(COST_PER_MIN))
# Make plot
p + geom_boxplot(aes(SERVICE, COST_PER_MIN, fill=SERVICE)) +
  geom_text(data = p_med_costmin, aes(x = SERVICE, y = med_costmin, label = round(med_costmin, 3)), size = 3, vjust = -1)+
  facet_wrap(~AM_PM) +
  ggtitle("Distribution of Cost/Min by Service and AM/PM Rush")+
  theme(legend.position = "none")

#Wait time - histogram
p + geom_histogram(aes(WAIT_TIME,..density.., fill=SERVICE), color="black", binwidth = 1) +
  facet_grid(SERVICE~AM_PM) +
  ggtitle("Distribution of Wait Time by Service and AM/PM Rush")+
  theme(legend.position = "none")

#Total duration - histogram
p + geom_histogram(aes(TOTAL_DURATION,..density.., fill=SERVICE), color="black", binwidth = 2) +
  facet_grid(SERVICE~AM_PM) +
  ggtitle("Distribution of Total Duration by Service and AM/PM Rush")+
  theme(legend.position = "none")

#Total duration - box plot
# Calculate medians to label plot
p_med_dur <- data2 %>% group_by(SERVICE, AM_PM) %>% summarise(med_dur=median(TOTAL_DURATION))
# Make plot
p + geom_boxplot(aes(SERVICE, TOTAL_DURATION, fill=SERVICE)) +
  geom_text(data = p_med_dur, aes(x = SERVICE, y = med_dur, label = med_dur), size = 3, vjust = -1)+
  facet_wrap(~AM_PM) +
  ggtitle("Distribution of Duration by Service and AM/PM Rush")+
  theme(legend.position = "none")

########SPEARMAN AND MANN-WHITNEY U TEST

#Spearman -> cor(x,y,method="spearman")
#Testing whether total ride duration and total cost are correlated
sp_dur_cost <- cor.test(data2$TOTAL_DURATION, data2$COST, method="spearman", exact=F)
print(sp_dur_cost)

#Testing whether wait time and total cost are correlated
sp_wait_cost <- cor.test(data2$WAIT_TIME, data2$COST, method="spearman", exact=F)
print(sp_wait_cost)

#Testing whether wait time and total cost/min are correlated
sp_wait_costmin <- cor.test(data2$WAIT_TIME, data2$COST_PER_MIN, method="spearman", exact=F)
print(sp_wait_costmin)

#Mann-Whitney - Lyft comes first in the list of factors so less would test if Lyft costs less than Uber
#Tests prob that a randomly selected Uber price is greater than a randomly selected Lyft price
wilcox.test(data2$COST~data2$SERVICE, alternative="less", exact=F)
#Same test just for AM
wilcox.test(data2_AM$COST~data2_AM$SERVICE, alternative="less", exact=F)
#Same test just for PM
wilcox.test(data2_PM$COST~data2_PM$SERVICE, alternative="less", exact=F)

#Tests prob that a randomly selected Uber cost/min is greater than a rand sel Lyft cost/min
wilcox.test(data2$COST_PER_MIN~data2$SERVICE, alternative="less", exact=F)


#######PLOTS OVER TIME:

#Plot price over time AM, all days combined/stratified by day of week (5 plots)
data2_AM %>% ggplot() + geom_point(aes(TIME, COST, color=SERVICE))+
  facet_wrap(~DAY_OF_WK, nrow = 1) +
  ggtitle("Morning Commute Cost vs Time of Day")+
  xlab("Time of Day")+
  ylab("Cost ($)")

#Plot price over time PM, all days combined/stratified by day of week (5 plots)
data2_PM %>% ggplot() + geom_point(aes(TIME, COST, color=SERVICE))+
  facet_wrap(~DAY_OF_WK, nrow = 1) +
  ggtitle("Evening Commute Cost vs Time of Day")+
  xlab("Time of Day")+
  ylab("Cost ($)")

#Plot average price in 15 min increments, AM
data2 %>% 
  group_by(inc=cut(as.numeric(TIME), breaks=c(seq(8,10,.25), seq(17,19,.25)))) %>%
  summarize(mean=mean(COST)) %>%
  ggplot()+geom_col(aes(inc, mean))

#Plot of cost vs total duration, color by service
p + geom_point(aes(TOTAL_DURATION, COST, color=SERVICE)) +
  ggtitle("Cost vs Total Duration") +
  xlab("Cost ($)")+
  ylab("Total Duration")

#Plot of cost vs total duration, color by total duration
p + geom_point(aes(TOTAL_DURATION, COST, color=as.numeric(abs(TIME_FROM_MID))))+
  ggtitle("Cost vs Total Duration") +
  xlab("Cost ($)")+
  ylab("Total Duration")+
  facet_wrap(~AM_PM)

p + geom_point(aes(TOTAL_DURATION, COST, color=SERVICE)) +
  facet_grid(AM_PM~.)

#AM only
data2 %>% filter(AM_PM=="AM") %>% ggplot() +
  geom_point(aes(TOTAL_DURATION, COST, color=as.numeric(TIME), shape=SERVICE))

#PM only
data2 %>% filter(AM_PM=="PM") %>% ggplot() +
  geom_point(aes(TOTAL_DURATION, COST, color=as.numeric(TIME), shape=SERVICE))


#### Ray look through this and clean it
###################################################


data2 %>% ggplot(aes(x = TOTAL_DURATION, y = COST, label = DATETIME)) +  
  geom_abline(intercept = log10(data2$COST_PER_MIN), lty=2, col="darkgrey") +
  geom_point(aes(color=WAIT_TIME), size = 3) +
  geom_text_repel() + 
  scale_x_log10() +
  scale_y_log10() +
  xlab("TOTAL DUATION  (log scale)") + 
  ylab("COST of service (log scale)") +
  ggtitle("COST of service with TOTAL DURATION") +
  scale_color_discrete(name="WAIT_TIME") +
  theme_economist()




#More analysis ideas:
#Research Q for website: How much $ do you lose by not knowing about the cheaper service
#(or how much monday are you saving by being savvy). -> t test? And stratify at different times of day

#Graph with x=time of day, y=some outcome (cost, duration), stratify the plot by morning/night
#   Use painted looking plot
#Somehow get a map and plot the stations on it
#Bar graph that shows average cost by hour (similar to a line graph but would have some body to it)

#Incoporate weather data

# boston rush hour
library(ggmap) 
library(Rcpp)
library(sp)
library(ggplot2)
library(maps)
library(mapdata)
library(RColorBrewer)
library(ggrepel)



devtools::install_github("hadley/ggplot2@v2.2.0")

library(ggmap)

route_df <- route(from = "107 Avenue Louis Pasteur Boston, MA 02115",
                  to = "1 Harvard Yard Cambridge, MA 02138",
                  structure = "route")

my_map <- get_map("107 Avenue Louis Pasteur Boston, MA 02115", zoom = 13)

#Save route map into images folder
png(filename="Images/route_map.png")
ggmap(my_map) +
  geom_path(aes(x = lon, y = lat), color = "red", size = 1.5,
            data = route_df, lineend = "round")
dev.off()


bostonMap <- qmap("boston", zoom = 12)  #First, get a map of Boston
#Combine to form one dataset
vand <- geocode("107 Avenue Louis Pasteur Boston, MA 02115")
vand
widener <- geocode("1 Harvard Yard Cambridge, MA 02138")
widener

#Need to pull X and Y from a dataset of longitude and latitude if we want multiple points
start<- bostonMap+
  geom_point(aes(x = vand$lon, y = vand$lat), data = data2, size=6) ##This adds the points to it

start



end<- bostonMap+
  geom_point(aes(x = widener$lon, y = widener$lat), data = data2, size=6) ##This adds the points to it

end


library(tidyverse)
library(maps)
library(geosphere)


start <- c(-71.10388 , 42.33746)
end <- c(-71.11625 , 42.37492)
data3=rbind(start, end) %>% as.data.frame()
colnames(data3)=c("long","lat")







library(ggmap)

route_df <- route(from = "107 Avenue Louis Pasteur Boston, MA 02115",
                  to = "1 Harvard Yard Cambridge, MA 02138",
                  structure = "route")

my_map <- get_map("107 Avenue Louis Pasteur Boston, MA 02115", zoom = 13)

ggmap(my_map) +
  geom_path(aes(x = lon, y = lat), color = "red", size = 1.5,
            data = route_df, lineend = "round")





