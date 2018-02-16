## Congressional Tweets - Sketch
## Output: N/A
## c. Tue Feb 13 12:28:42 CST 2018

## Note: Convert from package, "twitteR", to "rtweet" in order to access updated API with full 240 character formatting.


###################
## PACKAGE SETUP ##
###################

library(rtweet)
library(dplyr)


#################
## IMPORT DATA ##
#################

senate_df <- read.csv("Output/senateProfile_URLs.csv", stringsAsFactors = FALSE)


####################
## SCRAPE TWITTER ##
####################

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