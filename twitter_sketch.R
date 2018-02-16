## Congressional Tweets - Twitter Sketch
##
##

library(dplyr)
library(rtweet)

## Import Senate Data and correct missing/incorrect information
senateProfile_tbl <- read.csv("Output/senateProfile_tbl.csv", stringsAsFactors = FALSE)

## Missing data from: Bill Cassidy R La. [16], Amy Klobuchar D Minn. [54], Rand Paul R Ky. [70]
senateProfile_tbl$twitter_url[16] <- "https://twitter.com/BillCassidy"
senateProfile_tbl$twitter_handle[16] <- "BillCassidy"

senateProfile_tbl$twitter_url[54] <- "https://twitter.com/amyklobuchar"
senateProfile_tbl$twitter_handle[54] <- "amyklobuchar"

senateProfile_tbl$twitter_url[70] <- "https://twitter.com/RandPaul"
senateProfile_tbl$twitter_handle[70] <- "RandPaul"

## Out-of-date usernames: Tim Kaine [51], Todd Young [100]
senateProfile_tbl$twitter_url[51] <- "https://twitter.com/timkaine"
senateProfile_tbl$twitter_handle[51] <- "timkaine"

senateProfile_tbl$twitter_url[100] <- "https://twitter.com/SenToddYoung"
senateProfile_tbl$twitter_handle[100] <- "SenToddYoung"


## Get basic profile information w/Twitter API, append to senateProfile table
twitterData <- lookup_users(senateProfile_tbl$twitter_handle)

df <- cbind(senateProfile_tbl, twitterData)

## Calculate timeline activity

## df = {name, ideology, statuses/day, }

## Download tweets, save as ds_Name_timeline.csv



View(x)

# - - -


library(dplyr)

## Import data...

twitter_handles <- senate_df$twitter_handle[senate_df$twitter_handle != ""]
n <- length(twitter_handles)

## Note that Tim Kain's handle is incorrect.

for (i in 71:n) {
  
  # Progress meter
  print(paste("Progress: ", i, "/", n))
  
  userName <- twitter_handles[i]
  
  user <- getUser(userName)
  
  statusCount <- user$statusesCount
  
  # Original content from primary user timeline
  original_content <- userTimeline(user, n=user$statusesCount, 
                                   includeRts = TRUE, excludeReplies = FALSE)
  
  original_content <- twListToDF(original_content)
  
  ## Write data
  write.csv(original_content, paste0("Data/Tweets/", userName, "_timeline.csv"), row.names = FALSE)
  
  x <- sample(c(10, 20, 30, 40, 50, 60), 1)
  print(paste("Sleeping for", x, "seconds..."))
  
  Sys.sleep(x)
}

userName <- "CoryBooker"

user <- getUser(userName)

statusCount <- user$statusesCount

# Original content from primary user timeline
original_content <- userTimeline(user, n=user$statusesCount, 
                                 includeRts = TRUE, excludeReplies = TRUE)

original_content <- twListToDF(original_content)

original_content %>%
  select(text, favoriteCount, retweetCount, truncated, created, id, isRetweet) %>%
  arrange(desc(isRetweet == TRUE), desc(retweetCount)) %>%
  View()



range(original_content$created)
median(original_content$favoriteCount)
median(original_content$retweetCount)

boxplot(original_content$retweetCount)

## Write data
write.csv(original_content, paste0("Data/Tweets/", userName, "_timeline.csv"), row.names = FALSE)