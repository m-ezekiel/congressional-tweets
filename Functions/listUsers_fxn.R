# listUsers_fxn.R
# c. Fri Sep 29 00:27:10 CDT 2017

# Display account names for locally available Twitter data
listUsers <- function() {
  files <- list.files("Data/Twitter/")

  files <- gsub("Senate_D_", "", files)
  files <- gsub("Senate_R_", "", files)
  files <- gsub("Senate_ID_", "", files)
  
  files <- gsub("_hashtags.csv", "", files)
  files <- gsub("_mentions.csv", "", files)
  files <- gsub("_timeline.csv", "", files)

  unique(files)
}