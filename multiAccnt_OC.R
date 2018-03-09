## Congressional Tweets - Get Original Twitter Content and augment stats on MultiAccount Table
## Input: multiAccount_tbl
## Output: original content and update multiAccount table w/stats
## c. Thu Mar  8 16:22:41 CST 2018

multiAccnt_tbl <- read.csv("Output/multiAccount_tbl.csv", stringsAsFactors = FALSE)

## Arrange profile table to accomodate alphabetical filenames
multiAccnt_tbl <- multiAccnt_tbl %>%
  arrange(chamber, party, screen_name)

filenames <- list.files("Data/Twitter/")[1:691]
n <- length(filenames)

for (i in 529:n) {
  
  # Progress meter
  print(paste("Progress: ", i, "/", n))

  filepath <- paste0("Data/Twitter/", filenames[i])
  
  df <- read.csv(filepath, stringsAsFactors = FALSE)
    
  # User information
  user_id <- df$user_id[1]
  user_name <- df$screen_name[1]

  ## Data Validation
  if (multiAccnt_tbl$screen_name[i] != user_name) {
    print(user_name)
    break()
  }
    

  ######################
  ## ORIGINAL CONTENT ##
  ######################
  
  original_content <- df %>%
    filter(is_quote == FALSE, is_retweet == FALSE, 
           reply_to_status_id == "" | is.na(reply_to_status_id), 
           reply_to_user_id == "" | is.na(reply_to_user_id))
  
  
  ################################
  ## ADD STATS TO PROFILE TABLE ##
  ################################
  
  ## Original content observations
  n_obs_oc <- nrow(original_content)
  multiAccnt_tbl$n_obs_oc[i] <- n_obs_oc

  ## Original content observations w/photo media URL
  multiAccnt_tbl$n_obs_photo[i] <- length(which(original_content$media_type=="photo"))
  
  ## Date range for full timeline
  multiAccnt_tbl$earliest_status_oc[i] <- as.character(original_content$created_at[n_obs_oc])
  multiAccnt_tbl$latest_status_oc[i] <- as.character(original_content$created_at[1])
  
  ## Original content summary statistics
  multiAccnt_tbl$mean_favCount_oc[i] <- round(mean(original_content$favorite_count), 2)
  multiAccnt_tbl$median_favCount_oc[i] <- round(median(original_content$favorite_count), 2)
  multiAccnt_tbl$stdDev_favCount_oc[i] <- round(sd(original_content$favorite_count), 2)
  multiAccnt_tbl$mean_rtCount_oc[i] <- round(mean(original_content$retweet_count), 2)
  multiAccnt_tbl$median_rtCount_oc[i] <- round(median(original_content$retweet_count), 2)
  multiAccnt_tbl$stdDev_rtCount_oc[i] <- round(sd(original_content$retweet_count), 2)
  
  ################
  ## WRITE DATA ##
  ################
  
  ## Original Content
  oc_filepath <- gsub("timeline", "originalContent", filepath)
  write.csv(original_content, oc_filepath, row.names = FALSE)
}

## Write data
write.csv(multiAccnt_tbl, "Output/multiAccount_tbl_2018-03-08.csv", row.names = FALSE)
