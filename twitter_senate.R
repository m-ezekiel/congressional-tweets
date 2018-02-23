## Congressional Tweets - Twitter Senate
## Input: 
## Output: 
## c. Fri Feb 23 15:25:23 CST 2018

library(dplyr)
library(rtweet)
library(lubridate)

# ## Super rudimentary timeline activity calculation
# start <- ymd_hms(df$account_created_at[1])
# end <- ymd_hms("2018-02-15 13:58:50 UTC")
# time.interval <- start %--% end
# time.duration <- as.duration(time.interval)
# time.period <- as.period(time.interval)
# days <- time.duration / ddays(1)
# df$statuses_count[1] / days

## Download tweets, save as ds_Name_timeline.csv
## df = {..., n_obs_timeline, n_obs_OC, propOriginalContent, earliest_status, latest_status}

## Import Legislator Profile Data and format user_id column
senateProfile_tbl <- read.csv("Output/senateProfile_tbl.csv", stringsAsFactors = FALSE)

## Update link address to get full-size images
# senateProfile_tbl$profile_image_url <- gsub("_normal", "_400x400", senateProfile_tbl$profile_image_url)

#####################
## Download Tweets ##
#####################
n <- nrow(senateProfile_tbl)

for (i in 1:n) {
  
  # Progress meter
  print(paste("Progress: ", i, "/", n))
  
  # User information
  user_id <- gsub("x", "", senateProfile_tbl$user_id[i])
  user_name <- senateProfile_tbl$screen_name[i]
  user_party <- senateProfile_tbl$party[i]
  user_ideology <- senateProfile_tbl$govTrack_ideology[i]
  user_leadership <- senateProfile_tbl$govTrack_leadership[i]

  print(paste("Progress: ", user_name))
  
  ##############
  ## TIMELINE ##
  ##############
  
  # Get maximum allowed tweets from user timeline
  # Search w/user_id is preferable because it persists beyond screen_name changes
  user_timeline <- get_timeline(user_name, n = 3200)
  
  ## Extract hastags and mentions
  user_TL_hashtags <- as.data.frame(sort(table(na.omit(unlist(user_timeline$hashtags))), 
                                      decreasing = TRUE))
  names(user_TL_hashtags) <- c("Hashtag", "Frequency")
  user_TL_mentions <- as.data.frame(sort(table(na.omit(unlist(user_timeline$mentions_screen_name))), 
                                      decreasing = TRUE))
  names(user_TL_mentions) <- c("Mention", "Frequency")
  
  # Append screen_name for table joins
  user_TL_hashtags$screen_name <- user_name
  user_TL_mentions$screen_name <- user_name
  

  ######################
  ## ORIGINAL CONTENT ##
  ######################
  
  original_content <- user_timeline %>%
    filter(is_quote == FALSE, is_retweet == FALSE, is.na(reply_to_screen_name))

  ## Extract hastags and mentions
  user_OC_hashtags <- as.data.frame(sort(table(na.omit(unlist(original_content$hashtags))),
                                         decreasing = TRUE))
  names(user_OC_hashtags) <- c("Hashtag", "Frequency")
  user_OC_mentions <- as.data.frame(sort(table(na.omit(unlist(original_content$mentions_screen_name))), 
                                         decreasing = TRUE))
  names(user_OC_mentions) <- c("Mention", "Frequency")
  
  # Append screen_name for table joins
  user_OC_hashtags$screen_name <- user_name
  user_OC_mentions$screen_name <- user_name

  ######################
  ## TEXT ONLY TWEETS ##
  ######################
  
  text_only <- original_content %>%
    filter(is.na(urls_url), is.na(media_url))
    
  
  ################################
  ## ADD STATS TO PROFILE TABLE ##
  ################################
  n_obs <- nrow(user_timeline)
  n_OC <- nrow(original_content)
  n_text <- nrow(text_only)
  
  ## Observations and original content
  senateProfile_tbl$n_obs_timeline[i] <- n_obs
  senateProfile_tbl$n_obs_origContent[i] <- n_OC
  senateProfile_tbl$n_obs_textOnly[i] <- n_text
  senateProfile_tbl$prop_origContent[i] <- n_OC / n_obs
  senateProfile_tbl$prop_textOnly[i] <- n_text / n_obs
  
  ## Date range for full timeline
  senateProfile_tbl$earliest_status[i] <- as.character(user_timeline$created_at[n_obs])
  senateProfile_tbl$latest_status[i] <- as.character(user_timeline$created_at[1])
  
  ## Original Content summary statistics
  senateProfile_tbl$mean_favCount_OC[i] <- mean(original_content$favorite_count)
  senateProfile_tbl$median_favCount_OC[i] <- median(original_content$favorite_count)
  senateProfile_tbl$stdDev_favCount_OC[i] <- sd(original_content$favorite_count)
  senateProfile_tbl$mean_rtCount_OC[i] <- mean(original_content$retweet_count)
  senateProfile_tbl$median_rtCount_OC[i] <- median(original_content$retweet_count)
  senateProfile_tbl$stdDev_rtCount_OC[i] <- sd(original_content$retweet_count)
  
  ## Text Only summary statistics
  senateProfile_tbl$mean_favCount_text[i] <- mean(text_only$favorite_count)
  senateProfile_tbl$median_favCount_text[i] <- median(text_only$favorite_count)
  senateProfile_tbl$stdDev_favCount_text[i] <- sd(text_only$favorite_count)
  senateProfile_tbl$mean_rtCount_text[i] <- mean(text_only$retweet_count)
  senateProfile_tbl$median_rtCount_text[i] <- median(text_only$retweet_count)
  senateProfile_tbl$stdDev_rtCount_text[i] <- sd(text_only$retweet_count)
  
  ## Preview hashtag usage
  print(user_name)
  try(print(user_OC_hashtags$Hashtag[1:10]))

  ################
  ## WRITE DATA ##
  ################
  filename <- paste0(senateProfile_tbl$chamber[i], "_", 
                     senateProfile_tbl$party[i], "_", 
                     senateProfile_tbl$screen_name[i])

  ## Timeline
  write_as_csv(user_timeline, file_name = paste0("Data/Twitter/", filename, "_timeline.csv"))
  write_as_csv(user_TL_hashtags, file_name = paste0("Data/Twitter/", filename, "_hashtags.csv"))
  write_as_csv(user_TL_mentions, file_name = paste0("Data/Twitter/", filename, "_mentions.csv"))
  
  ## Original Content
  write_as_csv(original_content, file_name = paste0("Data/Twitter/", filename, "_originalContent.csv"))
  write_as_csv(user_OC_hashtags, file_name = paste0("Data/Twitter/", filename, "_OC_hashtags.csv"))
  write_as_csv(user_OC_mentions, file_name = paste0("Data/Twitter/", filename, "_OC_mentions.csv"))
  
  ## Text Only
  write_as_csv(text_only, file_name = paste0("Data/Twitter/", filename, "_textOnly.csv"))
  
  ## Download Profile Image
  # image_link <- senateProfile_tbl$profile_image_url[i]
  # download.file(image_link, paste0("Data/Twitter/", filename, "_profileImage.jpg"), mode = 'wb')
}

## Write data
write.csv(senateProfile_tbl, "Output/senateProfile_tbl_2018-02-23.csv", row.names = FALSE)
