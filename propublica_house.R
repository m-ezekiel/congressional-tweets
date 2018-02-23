## Congressional Tweets - ProPublica House Profile Table
## Input: propublica house table URLS
## Output: 
## c. Tue Feb 20 13:52:09 CST 2018

## Package setup
library(dplyr)
library(ngram)
library(rvest)
library(stringr)
library(stringi)
library(tidyr)
library(tm)
library(rtweet)

##################################
## PROPUBLICA HOUSE LINK TABLE ##
##################################

## Table of sponsorship and vote alignment
house_link <- read_html("https://projects.propublica.org/represent/members/115/house")
house_tbl <- html_table(house_link)
## Convert to dataframe and remove empty column at col_index == 1
house_tbl <- house_tbl[[1]][ , -1]

## Remove Diacritics 
house_tbl$Member <- stri_trans_general(house_tbl$Member, "Latin-ASCII")

## Shape Data
## Use " - " seperator to clarify from hyphenated names
df <- separate(house_tbl, col = "Member", into = c("full_name", "state"), sep = " - ")
df$full_name <- stripWhitespace(df$full_name)

## Extract name tokens
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
  } else if (wordCount == 5) {
    df$firstName[i] <- tokens[1]
    df$middleName[i] <- tokens[2]
    df$lastName[i] <- tokens[3]
    df$party[i] <- tokens[5]
  }
}

## Append profile URLs to preserve ProPublica legislator ordering...



####################################
## PROPUBLICA HOUSE PROFILE URLS ##
####################################

# ## ProPublica database of 115th U.S. Senate members
# house_html <- readLines("https://projects.propublica.org/represent/members/115/house")
# ## Write to local directory
# writeLines(house_html, "Output/propublica_house_html.txt")

## Import Data
house_html <- readLines("Output/propublica_house_html.txt")

## Extract html line numbers for links to legislator URLS
index <- seq(from=346, to=5142, by=11)
raw_profile_URLs <- trimws(house_html[index])

names <- trimws(gsub("<.*?>", "", raw_profile_URLs))

## Parse html to extract URLs
rm_span <- gsub("<span.*?a>", "", raw_profile_URLs)
rm_a <- gsub("<a href=\"", "", rm_span)
rm_tag <- gsub("\\\">", "", rm_a)

profile_URLs <- paste0("https://projects.propublica.org", rm_tag)

## Append chamber
df$chamber <- "House"

df$propublica_url <- profile_URLs


## Correct name formatting in order to match houseAnalysis.csv:
# row=68, Emanuel Cleaver II D
df$lastName[68] <- "Cleaver"
df$middleName[68] <- ""
# row=301, Bill Pascrell Jr. D
df$lastName[301] <- "Pascrell"
df$middleName[301] <- ""
# row=352, Gregorio Kilili Camacho Sablan, D
df$lastName[352] <- "Sablan"
df$middleName[352] <- "Kilili Camacho"


## Arrange alphabetically to clarify name overlap
df <- df %>%
  arrange(lastName, state)

## Compare reference tables
houseAnalysis <- read.csv("Output/houseAnalysis.csv", stringsAsFactors = FALSE)
# View(houseAnalysis)
# View(df)

## Append district code to lastName to match houseAnalysis.csv 
nameTable <- table(df$lastName)
commonNames <- names(nameTable[table(df$lastName) > 1])

for (i in 1:length(commonNames)) {
  source_index <- grep(commonNames[i], houseAnalysis$lastName)
  target_index <- which(df$lastName == commonNames[i])
  
  ## Replace df lastName with houseAnalysis lastName
  if (length(source_index) == length(target_index))
    df$lastName[target_index] <- houseAnalysis$lastName[source_index]
  if (length(source_index) != length(target_index))
    print(paste("Error at", commonNames[i]))
}

## Verify duplicates: Green (TX), Johnson (TX), Maloney (NY), Rooney (FL), Scott (GA), Smith (NJ/NE)
View(df)

# Update lastName to match the houseAnalysis table
# AG - tx9, GG - tx29, EBJ - tx30, SJ - tx3, SM - ny18, CBM - ny12, FR - fl19, TR - fl17, ...
df$lastName[160] <- "Green [TX9]"
df$lastName[161] <- "Green [TX29]"
df$lastName[198] <- "Johnson [TX30]"
df$lastName[199] <- "Johnson [TX3]"
df$lastName[253] <- "Maloney [NY18]"
df$lastName[254] <- "Maloney [NY12]"
df$lastName[336] <- "Rooney [FL19]"
df$lastName[337] <- "Rooney [FL17]"
df$lastName[364] <- "Scott [GA8]"
df$lastName[365] <- "Scott [GA13]"
df$lastName[380] <- "Smith [NJ4]"
df$lastName[381] <- "Smith [NE3]"



## Remove party affiliation from df$full_name column (minus 2 characters b/c stripped whitespace)
for (i in 1:nrow(df)) 
  df$full_name[i] <- substring(df$full_name[i], first = 1, last = nchar(df$full_name[i]) - 2)

## Data Integrity: script to parse the names inside the URLs and verify that they match the legislators.
## ...


######################
## Get Twitter URLS ##
######################

n <- nrow(df)
twitter_URL <- NULL

## Scrape propublica URL for Twitter link and append to senateProfile table

for (i in 415:n) {
  print(paste("Progress: ", i, "/", n))
  
  raw_html <- readLines(df$propublica_url[i])
  # Build in writelines script to avoid connectivity req for future analysis
  # writeLines(raw_html, "Data/ProPublica/")
  
  twitter_URL <- raw_html[358]
  twitter_URL <- trimws(twitter_URL)
  twitter_URL <- gsub("<li><a href=\"", "", twitter_URL)
  twitter_URL <- gsub("\">Twitter</a></li>", "", twitter_URL)
  
  df$twitter_url[i] <- twitter_URL
  
  # Pause to avoid flooding server http requests
  Sys.sleep(sample(1:3, 1))
}

View(df)


################################
## Fix missing/incorrect data ##
################################

# Speaker Ryan
df$twitter_url[352] <- "https://twitter.com/SpeakerRyan"

# House reps
df$twitter_url[6] <- "https://twitter.com/justinamash"
df$twitter_url[67] <- "https://twitter.com/LacyClayMO1"
df$twitter_url[76] <- "https://twitter.com/KYComer"
df$twitter_url[146] <- "https://twitter.com/GregForMontana"  ## Not verified
df$twitter_url[196] <- "https://twitter.com/RepMikeJohnson"
df$twitter_url[257] <- "https://twitter.com/RogerMarshallMD"
df$twitter_url[308] <- "https://twitter.com/collinpeterson"  ## Not verified
df$twitter_url[334] <- "https://twitter.com/DanaRohrabacher"
df$twitter_url[353] <- "https://twitter.com/Kilili_Sablan"

df$twitter_url[292] <- "https://twitter.com/DevinNunes"

##########################
## TWITTER PROFILE INFO ##
##########################

## Extract Twitter usernames
df$twitter_handle <- gsub("https://twitter.com/", "", df$twitter_url)

## Get basic profile information w/Twitter API, append to houseProfile table
twitterData <- lookup_users(df$twitter_handle)

## Remove legislators that do not have Twitter accounts
## (Madeleine Bordallo - D - Guam)
index <- which(df$twitter_handle == "")
df <- df[-index, ]

## Append Twitter data
houseProfile_tbl <- cbind(df, twitterData)

## Convert the Twitter user_id to a string to prevent weird rounding errors on data import
houseProfile_tbl$user_id <- paste0("x", houseProfile_tbl$user_id)

## Write data
write.csv(houseProfile_tbl, "Output/houseProfile_tbl.csv", row.names = FALSE)

## Clean up
rm(list = ls())