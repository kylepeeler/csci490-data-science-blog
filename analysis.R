winereviews = read.csv("~/Desktop/wine-reviews/winemag-data-130k-v2.csv")

summary(winereviews)

library(ggplot2)

scatter.smooth(x=winereviews$points, y=winereviews$price, main="Points ~ Price") 
cor(winereviews$points, winereviews$price, use = "complete.obs")

library(plyr)
View(ddply(winereviews, .(country), summarize,  Rate1=mean(points)))

library(tidyverse)
top_countries = winereviews %>% group_by(country) %>% count() %>% filter(n>1000)

top_country_points = winereviews %>% filter(country %in% top_countries$country) %>% select(country,points)
View(ddply(top_country_points, .(country), summarize,  AveragePts=mean(points)))

top20percentwines = winereviews[winereviews$points > quantile(winereviews$points,prob=1-20/100),]
bottom20percentwines = winereviews[winereviews$points < quantile(winereviews$points,prob=1-80/100),]

library(stringi)
library(tm)
library(topicmodels)
library(sentimentr)

#Create a vector of top 20 percent descriptions and a corpus object
top20doc = Corpus(VectorSource(top20percentwines$description))
# Remove stopwords, punctuation, and convert to lower case
top20doc = tm_map(top20doc, content_transformer(tolower))
top20doc = tm_map(top20doc, removePunctuation)
top20doc = tm_map(top20doc, removeWords, stopwords("english"))

#create a matrix of docs and terms
top20dtm = DocumentTermMatrix(top20doc)
rowTotals = apply(top20dtm, 1, sum)
top20dtm = top20dtm[rowTotals>0,]

# 6.) Run LDA on the Doc Term Matrix, Print out the top key words in each topic
lda = LDA(top20dtm, k=3)
tweets.df$topic = topics(lda)
terms(lda, 10)

# 7.) Calculate the frequencies of words in the corpus and create a word cloud
freqr = colSums(as.matrix(dtm))
View(freqr)
library(wordcloud)
wordcloud(names(freqr), freqr, min.freq=40)