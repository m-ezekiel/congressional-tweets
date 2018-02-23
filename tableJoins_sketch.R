## Congressional Tweets - Table Joins Sketch
## Input: senateProfile_tbl, senateAnalysis
## Output: legislative profile tables
## c. Sat Feb 17 13:18:56 CST 2018

library(dplyr)

## Import Data
senateProfile_tbl <- read.csv("Output/senateProfile_tbl.csv", stringsAsFactors = FALSE)
senateAnalysis <- read.csv("Output/senateAnalysis.csv", stringsAsFactors = FALSE)

tbl_join <- inner_join(senateProfile_tbl, senateAnalysis, "lastName")

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
         profile_banner_url, profile_background_url)

## Write data
write.csv(df, "Output/senateProfile_tbl.csv", row.names = FALSE)

## Clean up
rm(list = ls())