###################################################
######### Chargement des librairies ###############
###################################################

library(FactoMineR)
library(dplyr)
library(anytime)
library(lubridate)

###################################################
############ Chargement des données ###############
###################################################

data = read.csv("scrap_script/data2.csv")

btc = data %>% filter(market == "USDT-BTC")
eth = data %>% filter(market == "USDT-ETH")

tweet = read.csv("twitter/Extractdu07au08Mars.csv", sep = ";")

###################################################
############ Analyse factorielle ##################
###################################################

PCA(btc[c(1:5,7)])
PCA(eth[c(1:5,7)])

data.scaled = scale(data[,-c(6,8)])
data.scaled = cbind(data.scaled, data[,c(6,8)])

PCA(data.scaled[c(1:6)])



###################################################
############## Tweets par heure ###################
###################################################

tweetByHour = tweet %>%
  mutate(Time = as.POSIXct(anytime(date))) %>%
  group_by(date = date(Time),heure = hour(Time)) %>%
  summarise(count=n()) %>%
  arrange(date, heure)

tweet.ts = ts(tweetByHour$count, frequency = 24)
plot(tweet.ts)

btc.filtered = btc %>% 
  filter(date(T) > "2018-03-06", date(T) < "2018-03-08") %>%
  select(C, V)

btc.ts = ts(btc.filtered$C, frequency = 24)
plot(btc.ts)

btc.v.ts = ts(btc.filtered$V, frequency = 24)
plot(btc.v.ts)

par(mfrow=c(3,1))
par(mfrow=c(1,1))

