## Congressional Tweets - Multiple Accounts Sketch
## Input: legislatorProfile_tbl
## Output: data frame of associated usernames
## c. Sat Feb 24 12:48:00 CST 2018

library(rtweet)
library(dplyr)

legislatorProfile_tbl <- read.csv("Output/legislatorProfile_tbl.csv", stringsAsFactors = FALSE)

names <- legislatorProfile_tbl$full_name
n <- length(names)
df <- data.frame()

for (i in 1:n) {
  print(paste("Progress: ", i, "/", n))
  user_search <- search_users(names[i], n=10)
  user_search$query <- names[i]
  
  df <- rbind(df, user_search)
}

View(df)

## Get VERIFIED only

df <- df %>%
  filter(verified==TRUE)

## Remove accounts I already have (should have listed search query)
alt_names <- setdiff(df$screen_name, legislatorProfile_tbl$screen_name)

twitterData <- lookup_users(alt_names)
View(twitterData)


## Behind the scenes i ran the multiple_accounts script and manually associated alternate accounts with legislators including their personal and campaign accounts.
## The next step is to add the 

houseProfile_tbl <- read.csv("Output/houseProfile_tbl_2018-02-23.csv", stringsAsFactors = FALSE)
senateProfile_tbl <- read.csv("Output/senateProfile_tbl_2018-02-23.csv", stringsAsFactors = FALSE)

hp <- houseProfile_tbl[ , c("govTrack_id", "full_name")]
sp <- senateProfile_tbl[ , c("govTrack_id", "full_name")]

lp <- rbind(hp, sp)

## This data was pulled from a google doc I used to manually associate names 
multi <- read.csv("Data/multiple_accounts - legislatorProfile_tbl.csv", stringsAsFactors = FALSE)

df <- data.frame()
for (i in 1:nrow(multi)) {
  if (multi$alt_name1[i] != "") 
    df <- rbind(df, cbind(multi[i, 1:4], screen_name = multi$alt_name1[i]))
  if (multi$alt_name2[i] != "") 
    df <- rbind(df, cbind(multi[i, 1:4], screen_name = multi$alt_name2[i]))
}


## Join multiAccounts to original legislatorProfile_tbl
x <- inner_join(df, lp)
var_names <- names(x)
y <- senateProfile_tbl[ , var_names]
z <- houseProfile_tbl[ , var_names]

## append to legTable
new_df <- rbind(x, y, z)

multi_lp_tbl <- inner_join(new_df, legislatorProfile_tbl[1:8])

#################
## TWITER DATA ##
#################

twitterData <- lookup_users(multi_lp_tbl$screen_name)

updated_tbl <- cbind(multi_lp_tbl, twitterData)
# Remove extra sn column
updated_tbl <- updated_tbl[ , -5]

## Shape data
multiAccount_tbl <- updated_tbl %>%
  select(govTrack_id, full_name, chamber, party, state, bin,
         govTrack_desc, govTrack_ideology, proPub_votesAgainstParty,
         user_id, name, screen_name, location, description,
         statuses_count, followers_count, friends_count, favourites_count,
         verified, account_created_at, profile_expanded_url, profile_image_url) %>%
  arrange(govTrack_ideology)

## Write data using "rtweet" function to preserve user_ids
write_as_csv(multiAccount_tbl, "Output/multiAccount_tbl.csv")

## Clean up
rm(list = ls())
