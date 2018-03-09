## Congressional Tweets - Table Joins House
## Input: houseProfile_tbl, houseAnalysis
## Output: legislative profile tables
## c. Thu Feb 22 18:12:30 CST 2018

library(dplyr)

## Import Data
houseProfile_tbl <- read.csv("Output/houseProfile_tbl.csv", stringsAsFactors = FALSE)
houseAnalysis <- read.csv("Output/houseAnalysis.csv", stringsAsFactors = FALSE)

tbl_join <- inner_join(houseProfile_tbl, houseAnalysis, "lastName")

## Correct more names (sometimes it's faster to hard code it)
missingNames <- setdiff(houseProfile_tbl$lastName, tbl_join$lastName)
houseProfile_tbl$middleName[c(20,72,163,328,329,361)] <- ""

houseProfile_tbl$lastName[20] <- "Herrera Beutler"
houseProfile_tbl$lastName[72] <- "Watson Coleman"
houseProfile_tbl$lastName[163] <- "Lujan Grisham"

houseProfile_tbl$lastName[281] <- "Murphy [FL7]"
houseProfile_tbl$lastName[316] <- "Price [NC4]"

houseProfile_tbl$firstName[318] <- "Aumua"
houseProfile_tbl$lastName[318] <- "Amata"

houseProfile_tbl$lastName[328] <- "Blunt Rochester"
houseProfile_tbl$lastName[329] <- "McMorris Rodgers"
houseProfile_tbl$lastName[361] <- "Wasserman Schultz"


## Try again
tbl_join <- inner_join(houseProfile_tbl, houseAnalysis, "lastName")

## I'm also interested in average values for tweet virality to get individually relevant thresholds for popular content.  Like {propOriginalContent, avgLikes_OC, avgRTs_OC} on original content.
## Also proportion of tweets created since Jan 01, 2016 (?)

df <- tbl_join %>%
  mutate(proPub_sponsoredBills = SponsoredBills, proPub_cosponsoredBills = CosponsoredBills,
         proPub_votesAgainstParty = Votes.AgainstParty, proPub_missedVotes = Missed.Votes) %>%
  select(govTrack_id, full_name, lastName, middleName, firstName, 
         chamber, party, partyName, state,
         govTrack_desc, govTrack_ideology, govTrack_leadership,
         propublica_url, proPub_sponsoredBills, proPub_cosponsoredBills,
         proPub_votesAgainstParty, proPub_missedVotes,
         twitter_url, user_id, name, screen_name, location, description, url, verified,
         statuses_count, followers_count, friends_count, favourites_count, listed_count,
         account_created_at, account_lang, profile_url, profile_expanded_url, profile_image_url,
         profile_banner_url, profile_background_url) %>%
  ## IMPORTANT: only use accounts that have been verified by Twitter.
  filter(verified == TRUE)



## Write data
# write.csv(df, "Output/houseProfile_tbl.csv", row.names = FALSE)

## Clean up
rm(list = ls())
