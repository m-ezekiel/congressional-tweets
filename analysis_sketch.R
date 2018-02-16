## Congressional Tweets - Analysis Sketch
##
## c. Fri Feb 16 15:34:46 CST 2018

source("Functions/listUsers_fxn.R")
listUsers()

## Create null df; append ht, freq, screen_name, party, chamber

## Combine all hashtags with authorship, party and chamber
tweets <- read.csv("Data/Twitter/Senate_R_InhofePress_timeline.csv", stringsAsFactors = FALSE)

index <- grep("Up4Climate", tweets$hashtags)
index <- grep("climate", tweets$text, ignore.case = TRUE)


View(tweets[index, ])
