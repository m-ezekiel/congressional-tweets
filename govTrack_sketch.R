## Congressional Tweets - GovTrack Sketch
## Input: sponsorshipanalysis_*.txt
## Output: senateAnalysis.csv
## c. Tue Feb 13 12:28:42 CST 2018


## Package setup
library(dplyr)
library(stringi)
library(ggplot2)
library(tm)

## Import Data
senateAnalysis <- read.csv("Data/GovTrack/sponsorshipanalysis_s.txt", stringsAsFactors = FALSE)
houseAnalysis <- read.csv("Data/GovTrack/sponsorshipanalysis_h.txt", stringsAsFactors = FALSE)


#######################
## Remove Diacritics ##
#######################

senateAnalysis$name <- stri_trans_general(senateAnalysis$name, "Latin-ASCII")
houseAnalysis$name <- stri_trans_general(houseAnalysis$name, "Latin-ASCII")

# Remove whitespace
senateAnalysis$name <- trimws(senateAnalysis$name)
houseAnalysis$name <- trimws(houseAnalysis$name)

## Note that the house data also has district labels contained inside the name column
# senateAnalysis <- separate(senateAnalysis, col = "name", into = c("name", "district"), sep = " ")
# houseAnalysis <- separate(houseAnalysis, col = "name", into = c("name", "district"), sep = " ")


################
## Shape Data ##
################

## Ideology scale from 0 to 1 == "liberal" to "conservative"
## Leadership sclae from 0 to 1 == "follower" to "leader"

senateAnalysis <- senateAnalysis %>%
  mutate(govTrack_id = ID, 
         govTrack_ideology = ideology, 
         govTrack_desc = description,
         govTrack_leadership = leadership,
         lastName = name,
         partyName = party) %>%
  select(govTrack_id, lastName, partyName, govTrack_desc, govTrack_ideology, govTrack_leadership) %>%
  arrange(lastName)

houseAnalysis <- houseAnalysis %>%
  mutate(govTrack_id = ID, 
         govTrack_ideology = ideology, 
         govTrack_desc = description,
         govTrack_leadership = leadership,
         lastName = name,
         partyName = party) %>%
  select(govTrack_id, lastName, partyName, govTrack_desc, govTrack_ideology, govTrack_leadership) %>%
  arrange(lastName)

## See https://www.govtrack.us/about/analysis for full methodology


###############
## Plot Data ##
###############

# plot(senateAnalysis$govTrack_ideology, senateAnalysis$govTrack_leadership)


################
## Write Data ##
################

## df = {govTrack_id, lastName, party, govTrack_desc, alignment, leadership}
write.csv(senateAnalysis, "Output/senateAnalysis.csv", row.names = FALSE)
write.csv(houseAnalysis, "Output/houseAnalysis.csv", row.names = FALSE)

## Clean up
rm(list = ls())
