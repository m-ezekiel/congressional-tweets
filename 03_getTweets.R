## Congressional Tweets - Get Tweets
## Input: senateProfile_URLs, houseProfile_URLs
## c. Mon Feb  5 15:12:42 CST 2018

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
