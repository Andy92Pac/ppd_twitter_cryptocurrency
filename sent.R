library("syuzhet")
library("readr")
library("dplyr")
library("anytime")
library("lubridate")
library("ggplot2")
library("tseries")
library("FactoMineR")

data.twitter <- read_delim("twitter/28_31.csv", "\t", escape_double = FALSE, 
                   col_names = FALSE, trim_ws = TRUE)

colnames(data.twitter) <- c("username","date","RT","Fav","Text","geo","mentions","hashtag","id","permalinks")

t = as.data.frame(data.twitter)
colnames(t) <- c("username","date","RT","Fav","Text","geo","mentions","hashtag","id","permalinks")
te = t$Text
res = get_nrc_sentiment(te)
data.twitter = cbind(data.twitter, res)
clean.data = data.twitter %>% select(Text, date, colnames(res))

clean.data = clean.data %>%
  mutate(Time = as.POSIXct(date, format='%d/%m/%Y %H:%M'))

sent = clean.data %>% 
  group_by(date = date(Time),heure = hour(Time)) %>%
  mutate(count = n()) %>%
  summarize(
    sum(anger),
    sum(anticipation),
    sum(disgust),
    sum(fear),
    sum(joy),
    sum(sadness),
    sum(surprise),
    sum(trust),
    sum(negative),
    sum(positive)
  )

nb = clean.data %>% 
  group_by(date = date(Time),heure = hour(Time)) %>%
  summarize(count = n())

tot = cbind(sent, nb)

tot = tot %>% mutate(
  `sum(anger)` = `sum(anger)`/count,
  `sum(anticipation)` = `sum(anticipation)`/count,
  `sum(disgust)` = `sum(disgust)`/count,
  `sum(fear)` = `sum(fear)`/count,
  `sum(joy)` = `sum(joy)`/count,
  `sum(sadness)` = `sum(sadness)`/count,
  `sum(surprise)` = `sum(surprise)`/count,
  `sum(trust)` = `sum(trust)`/count,
  `sum(negative)` = `sum(negative)`/count,
  `sum(positive)` = `sum(positive)`/count
  )

ts.anger = ts(tot$`sum(anger)`, frequency = 24)
ts.anticipation = ts(tot$`sum(anticipation)`, frequency = 24)
ts.disgust = ts(tot$`sum(disgust)`, frequency = 24)
ts.fear = ts(tot$`sum(fear)`, frequency = 24)
ts.joy = ts(tot$`sum(joy)`, frequency = 24)
ts.sadness = ts(tot$`sum(sadness)`, frequency = 24)
ts.surprise = ts(tot$`sum(surprise)`, frequency = 24)
ts.trust = ts(tot$`sum(trust)`, frequency = 24)
ts.negative = ts(tot$`sum(negative)`, frequency = 24)
ts.positive = ts(tot$`sum(positive)`, frequency = 24)

plot(ts.anger)
ts.plot(tot[,c(3,12)],gpars= list(col=rainbow(10)))

only.tot = tot[,3:12]
only.tot.scaled = scale(only.tot)
ts.plot(only.tot.scaled[,c(9,10)], gpars= list(col=rainbow(10)))

cor(only.tot.scaled[,9], only.tot.scaled[,10])

PCA(only.tot.scaled)
