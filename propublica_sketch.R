## Congressional Tweets - ProPublica Sketch
## Input: propublica senate and house table URLS
## Output: 
## c. Mon Jan  8 00:17:54 CST 2018

## Package setup
library(dplyr)
library(ngram)
library(rvest)
library(stringr)
library(tidyr)
library(tm)
library(rtweet)

##################################
## PROPUBLICA SENATE LINK TABLE ##
##################################

## Table of sponsorship and vote alignment
senate_link <- read_html("https://projects.propublica.org/represent/members/115/senate")
senate_tbl <- html_table(senate_link)
## Convert to dataframe and remove empty column at col_index == 1
senate_tbl <- senate_tbl[[1]][ , -1]

## Shape Data
df <- separate(senate_tbl, col = "Member", into = c("full_name", "state"), sep = "-")
df$full_name <- stripWhitespace(df$full_name)

for (i in 1:nrow(df)) {
  wordCount <- wordcount(df$full_name[i])
  tokens <- unlist(strsplit(df$full_name[i], split = " "))
  
  if (wordCount == 3) {
    df$firstName[i] <- tokens[1]
    df$middleName[i] <- ""
    df$lastName[i] <- tokens[2]
    df$party[i] <- tokens[3]
  } else if (wordCount == 4) {
    df$firstName[i] <- tokens[1]
    df$middleName[i] <- tokens[2]
    df$lastName[i] <- tokens[3]
    df$party[i] <- tokens[4]
  }
}

## Correct name formatting in order to match senateAnalysis.csv:
# row=22, Catherine Cortez Masto D
df$lastName[22] <- "Cortez Masto"
df$middleName[22] <- ""
# row=58, Joe Manchin III D
df$lastName[58] <- "Manchin"
df$middleName[58] <- ""
# row=94, Chris Van Hollen D
df$lastName[94] <- "Van Hollen"
df$middleName[94] <- ""


## Remove party affiliation from df$full_name column
for (i in 1:nrow(df)) 
  df$full_name[i] <- substring(df$full_name[i], first = 1, last = nchar(df$full_name[i]) - 3)


####################################
## PROPUBLICA SENATE PROFILE URLS ##
####################################

# ## ProPublica database of 115th U.S. Senate members
# senate_html <- readLines("https://projects.propublica.org/represent/members/115/senate")
# ## Write to local directory
# writeLines(senate_html, "Output/propublica_senate_html.txt")

## Import Data
senate_html <- readLines("Output/propublica_senate_html.txt")

## Extract html line numbers for links to legislator URLS
index <- seq(from=346, to=1435, by=11)
raw_profile_URLs <- trimws(senate_html[index])

names <- trimws(gsub("<.*?>", "", raw_profile_URLs))

## Parse html to extract URLs
rm_span <- gsub("<span.*?a>", "", raw_profile_URLs)
rm_a <- gsub("<a href=\"", "", rm_span)
rm_tag <- gsub("\\\">", "", rm_a)

profile_URLs <- paste0("https://projects.propublica.org", rm_tag)

## Append chamber
df$chamber <- "Senate"

## Create profile table w/ProPublica URLs
senateProfile_tbl <- data.frame(df, propublica_url = profile_URLs, 
                                 stringsAsFactors = FALSE)

######################
## Get Twitter URLS ##
######################

n <- nrow(senateProfile_tbl)
twitter_URL <- NULL

## Scrape propublica URL for Twitter link and append to senateProfile table

for (i in 1:n) {
  print(paste("Progress: ", i, "/", n))
  
  raw_html <- readLines(senateProfile_tbl$propublica_url[i])
  
  twitter_URL <- raw_html[349]
  twitter_URL <- trimws(twitter_URL)
  twitter_URL <- gsub("<li><a href=\"", "", twitter_URL)
  twitter_URL <- gsub("\">Twitter</a></li>", "", twitter_URL)
  
  senateProfile_tbl$twitter_url[i] <- twitter_URL
  
  # Pause to avoid flooding server http requests
  Sys.sleep(sample(1))
}

View(senateProfile_tbl)


################################
## Fix missing/incorrect data ##
################################

## Missing data from: Bill Cassidy R La. [16], Amy Klobuchar D Minn. [54], Rand Paul R Ky. [70]
senateProfile_tbl$twitter_url[16] <- "https://twitter.com/BillCassidy"
senateProfile_tbl$twitter_url[54] <- "https://twitter.com/amyklobuchar"
senateProfile_tbl$twitter_url[70] <- "https://twitter.com/RandPaul"

## Out-of-date usernames: Tim Kaine [51], Todd Young [100]
senateProfile_tbl$twitter_url[51] <- "https://twitter.com/timkaine"
senateProfile_tbl$twitter_url[100] <- "https://twitter.com/SenToddYoung"

## Extract Twitter usernames
senateProfile_tbl$twitter_handle <- gsub("https://twitter.com/", "", 
                                         senateProfile_tbl$twitter_url)



#############################
## BASIC TWITTER GOES HERE ##
#############################

## Get basic profile information w/Twitter API, append to senateProfile table
twitterData <- lookup_users(senateProfile_tbl$twitter_handle)

df <- cbind(senateProfile_tbl, twitterData)

## Write data
write.csv(df, "Output/senateProfile_tbl.csv", row.names = FALSE)

## Clean up
rm(list = ls())
