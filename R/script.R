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

################################################
################################################

data = cbind(data, h1 = 0, h2 = 0)

for(i in 1:nrow(data)) {
  if(i == nrow(data)) {
    data[i,9] = 0
    data[i-1,10] = 0
  } 
  else if(i == nrow(data)-1) {
    data[i,9] = ifelse(data[i,1] - data[i+1,1]<0,1,0)
    data[i,10] = 0
  }
  else {
    data[i,9] = ifelse(data[i,1] - data[i+1,1]<0,1,0)
    data[i,10] = ifelse(data[i,1] - data[i+2,1]<0,1,0)
  }
}

head(data)

data.sub = data %>% 
  filter(market == "USDT-BTC") %>%
  mutate(date = date(anytime(T)), heure = hour(anytime(T))) %>%
  arrange(date, heure)

tee = data.frame(date = tot$date1, heure = tot$heure1, only.tot.scaled)
tee = as.data.frame(tee)
data.sub = as.data.frame(data.sub)
j = merge(data.sub, tee, by = c("date", "heure"))
j = j %>% arrange(date, heure)

#####################################################
#####################################################

join.data = j

pca.join = PCA(join.data, quanti.sup = c(3,4,5,6,7,9,12), quali.sup = c(1,2,8,10))
plot.PCA(pca.join, axes = c(1,3), choix = ("var"))

#####################################################
#####################################################

Y = join.data$h1
X = join.data[,13:22]

model = glm(Y ~ ., data = X, family = binomial(link = "logit"))


