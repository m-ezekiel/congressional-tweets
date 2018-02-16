## Congressional Tweets - Twitter Sketch
##
## c. Fri Feb 16 12:55:09 CST 2018

library(dplyr)
library(rtweet)
library(lubridate)

# ## Import Senate Data and correct missing/incorrect information
# senateProfile_tbl <- read.csv("Output/senateProfile_tbl.csv", stringsAsFactors = FALSE)
# 
# ## Get basic profile information w/Twitter API, append to senateProfile table
# twitterData <- lookup_users(senateProfile_tbl$twitter_handle)
# 
# df <- cbind(senateProfile_tbl, twitterData)
# 
# ## Write data
# write.csv(df, "Output/senateProfile_tbl.csv", row.names = FALSE)

# ## Super rudimentary timeline activity calculation
# start <- ymd_hms(df$account_created_at[1])
# end <- ymd_hms("2018-02-15 13:58:50 UTC")
# time.interval <- start %--% end
# time.duration <- as.duration(time.interval)
# time.period <- as.period(time.interval)
# days <- time.duration / ddays(1)
# df$statuses_count[1] / days

## Download tweets, save as ds_Name_timeline.csv

## Import data...
df <- read.csv("Output/senateProfile_tbl.csv", stringsAsFactors = FALSE)

for (i in 1:nrow(df)) {
  
  # Progress meter
  print(paste("Progress: ", i, "/", n))
  
  user_id <- df$user_id[i]
  user_name <- df$screen_name[i]

  # Get maximum allowed tweets from user timeline
  # Search w/user_id because it persists beyond screenname changes
  # Note that CoryBooker is the only senator with more than 3200 (6k+)
  user_timeline <- get_timeline(user_id, n = 3200)
  
  ## Extract hastags and mentions
  user_hashtags <- as.data.frame(sort(table(na.omit(unlist(user_timeline$hashtags))), 
                                      decreasing = TRUE))
  names(user_hashtags) <- c("Hashtag", "Frequency")
  
  user_mentions <- as.data.frame(sort(table(na.omit(unlist(user_timeline$mentions_screen_name))), 
                                      decreasing = TRUE))
  names(user_mentions) <- c("Mention", "Frequency")
  
  ## Preview hashtag usage
  print(df$name[i])
  print(user_hashtags$Hashtag[1:6])
  
  ## Write data
  filename <- paste0(df$chamber[i], "_", df$party[i], "_", df$screen_name[i])
  write_as_csv(user_timeline, file_name = paste0("Data/Tweets/", filename, "_timeline.csv"))
  write_as_csv(user_hashtags, file_name = paste0("Data/Tweets/", filename, "_hashtags.csv"))
  write_as_csv(user_mentions, file_name = paste0("Data/Tweets/", filename, "_mentions.csv"))
  
}




range(original_content$created)
median(original_content$favoriteCount)
median(original_content$retweetCount)

boxplot(original_content$retweetCount)

## Write data
write.csv(original_content, paste0("Data/Tweets/", userName, "_timeline.csv"), row.names = FALSE)