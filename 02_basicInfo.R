## Congressional Tweets - Basic Twitter Info
## Input: senateProfile_URLs, houseProfile_URLs
## c. Mon Feb  5 15:12:42 CST 2018

library(twitteR)
source("Functions/twitterConfig.R")

## Import data
senate_df <- read.csv("Output/senateProfile_URLs.csv", stringsAsFactors = FALSE)
n <- nrow(senate_df)

for (i in 1:n) {

  # Progress meter
  print(paste("Progress: ", i, "/", n))
  
  userName <- senate_df$twitter_handle[i]
  
  if (userName != "") {
    try(user <- getUser(userName))
    
    try(senate_df$statuses[i] <- user$statusesCount)
    try(senate_df$favorites[i] <- user$favoritesCount)
    try(senate_df$friends[i] <- user$friendsCount)
    try(senate_df$followers[i] <- user$followersCount)
    try(senate_df$created[i] <- as.character(user$created))
  }
}

View(senate_df)