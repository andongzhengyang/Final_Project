#Title: BST 260 Final Project
#Authors: Kara Higgins & Ray An

#TO DO BY MONDAY NOV. 20
# Kara
#   Redo univariate statistics, make plots look pretty and clean up code
#   Import weather data
#   Figure out code for Mann-Whitney U test and spearman correlation coefficent
# Ray:
#   Clean up code for regressions/plots so there is only one version of each
#   Try to figure out heat map and decide what will go into it
#   Find a good city map and figure out how to put points on it for beginning and end


#Packages
library(tidyverse)
library(lubridate)
library(stringr)
library(ggplot2)

#Import data
#Currently using 13NOV2017 freeze
data_location <- "C:/Users/kara.THETA_HQ/Documents/Harvard/Classes/Fall 2017/BST 260 Intro to Data Science/Final Project/Data/FREEZE_13NOV2017.csv"

data <- read.csv(data_location, stringsAsFactors = F)

#STEP 1
#Get data in correct format - specs are as follows: RAY will send to Kara by Sunday
#   DATE: Date of request. Format=date (need to specify further based on R formats avail.)
#   DAY_OF_WK: Day of week of request. Format=factor w/ 5 levels
#   REQUEST_DATETIME: Date and time combined. Format=R date
#   REQUEST_TIME: Time of request, calculated as hours/min since start of the day. Format=R time
#   SERVICE: Uber/Lyft. Format=factor w/ 2 levels
#   COST: Cost of ride. Format=numeric double
#   WAIT_TIME: Estimated wait time. Format=numeric
#   ARRIVAL_TIME: Estimated time of arrival. Format=R time (specify further)
#   ARRIVAL_DATETIME: Combined estimated date and time of arrival. Format=R date time.
#   TOTAL_DURATION: Estimated duration incl. wait time. Format=numeric
#   COLLECTOR: Kara/Ray. Format=factor w/ 2 levels
#   AM_PM: AM/PM request time. Format=Factor w/ 2 levels, need to derive\
#   COST_PER_MIN: Cost in dollars per minute of estimated duration. Format=numeric

data2 <- data %>% mutate(DATE=as.Date(DATE, format="%m/%d/%Y"),
                         DAY_OF_WK=as.factor(DAY_OF_WK),
                         DATETIME=as.POSIXct(paste(DATE,TIME),format="%Y-%m-%d %H:%M"),
                         TIME=DATETIME-as.POSIXct(paste(DATE,"00:00:00"), format="%Y-%m-%d %H:%M"),
                         SERVICE=as.factor(SERVICE),
                         ARRIVAL_DATETIME=as.POSIXct(paste(DATE,ARRIVAL_TIME),format="%Y-%m-%d %H:%M"),
                         ARRIVAL_TIME=ARRIVAL_DATETIME-as.POSIXct(paste(DATE,"00:00:00"), format="%Y-%m-%d %H:%M"),
                         COLLECTOR=as.factor(COLLECTOR),
                         AM_PM=as.factor(ifelse(TIME>8 & TIME<10, "AM", "PM")),
                         COST_PER_MIN=COST/as.numeric(TOTAL_DURATION)
                           )

#STEP 2
#Exploratory data analysis - KARA
#Get univariate stats on time, cost, wait time, total duration
#Are they normally distributed? What is the max/min for each variable, what is the sd like? What is the mean?
#Histograms, boxplots?

#Univariate analyses

summary(data2)

#ADD COMMENTS FOR EVERYTHING
p1 <- data2 %>% ggplot()
p1 + geom_histogram(aes(COST))
p1 + geom_boxplot(aes(SERVICE, COST))
p1 + geom_histogram(aes(WAIT_TIME), binwidth = 2)
p1 + geom_histogram(aes(TOTAL_DURATION))
p1 + geom_histogram(aes(COST_PER_MINUTE, fill=SERVICE))

#Cost, wait time are going to be very skewed to the right, can't do lin reg.

#STEP 3
#Exploratory continued...
#Plot price over time, all days combined/stratified by day of week (5 plots) - RAY
#T-test of total duration Uber vs. Lyft - RAY
#T-test of cost Uber vs. Lyft - RAY
#Linear regression: test which variables make sense to put in, try squaring/taking square roots, etc. - KARA

# Plot price over time

library(dslabs)
library(ggthemes)
library(ggrepel)


#ADD COMMENTS FOR EVERYTHING
p2 <- data2 %>% ggplot()

#Plot of total duration vs cost
p2 + geom_point(aes(TOTAL_DURATION, COST))

#Same plot, but adding color for SERVICE
p2 + geom_point(aes(TOTAL_DURATION, COST, color=SERVICE))

p2 + geom_point(aes(TOTAL_DURATION, COST, color=as.numeric(TIME)))

p2 + geom_point(aes(TOTAL_DURATION, COST, color=SERVICE)) +
  facet_grid(AM_PM~.)

#AM only
data2 %>% filter(AM_PM=="AM") %>% ggplot() +
  geom_point(aes(TOTAL_DURATION, COST, color=as.numeric(TIME), shape=SERVICE))

#PM only
data2 %>% filter(AM_PM=="PM") %>% ggplot() +
  geom_point(aes(TOTAL_DURATION, COST, color=as.numeric(TIME), shape=SERVICE))

#Can convert scale to log if needed


# Havent gone through this together yet
###################################################

p2 + geom_abline(intercept = log10(COST_PER_MIN), lty = 2, color = "darkgrey") +
  geom_point(aes(col=TIME), size = 3)  

p <- p + scale_color_discrete(name = "time1") 

ds_theme_set()

library(ggthemes)
p + theme_economist()



p + geom_point(size = 3) +  
  geom_text(nudge_x = 0.05) + 
  scale_x_continuous(trans = "log10") +
  scale_y_continuous(trans = "log10") 


p + geom_point(size = 3) +  
  geom_text(nudge_x = 0.05) + 
  scale_x_log10() +
  scale_y_log10()  


p + geom_point(size = 3) +  
  geom_text(nudge_x = 0.05) + 
  scale_x_log10() +
  scale_y_log10() +
  xlab("Price") + 
  ylab("Total duration") +
  ggtitle("price over time")


p + geom_point(size = 3, color ="blue")

p + geom_point(aes(col=time1), size = 3)



#t test
a <- 1:40
b <- a[seq(1, length(a), 2)]
b
# t test for total duration

a <- data2$TOTAL_DURATION[1:39]
b <- a[seq(1, length(a), 2)]
b

c <- data2$TOTAL_DURATION[2:40]
d <- a[seq(2, length(a), 2)]
d 

t.test(b,d) 

# t test for cost 

a <- data2$COST[1:39]
b <- a[seq(1, length(a), 2)]
b

c <- data2$COST[2:40]
d <- a[seq(2, length(a), 2)]
d 


t.test(b,d) 

#Kara will try out Mann-Whitney and Spearman code
#Ray might try to make a heat map if he has time

#More analysis ideas:
#Mann-Whitney U test
#Spearman correlation coefficient
#Research Q for website: How much $ do you lose by not knowing about the cheaper service
#(or how much monday are you saving by being savvy). -> t test? And stratify at different times of day
#More ideas:
# Heat map

#Graph with x=time of day, y=some outcome (cost, duration), stratify the plot by morning/night
#   Use painted looking plot
#Somehow get a map and plot the stations on it
#Bar graph that shows average cost by hour (similar to a line graph but would have some body to it)

#Incoporate weather data

