## Congressional Tweets - Topic-based Keywords sketch
## Input: houseProfile, senateProfile
## Output: legislatorProfile_tbl
## c. Sat Feb 24 12:48:00 CST 2018

library(dplyr)

houseProfile_tbl <- read.csv("Output/houseProfile_tbl_2018-02-23.csv", stringsAsFactors = FALSE)
senateProfile_tbl <- read.csv("Output/senateProfile_tbl_2018-02-23.csv", stringsAsFactors = FALSE)

legislatorProfile_tbl <- rbind(senateProfile_tbl, houseProfile_tbl)
legislatorProfile_tbl <- arrange(legislatorProfile_tbl, govTrack_ideology)


## Calculate number of legislators per bin
n <- nrow(legislatorProfile_tbl)
n_bins <- 53
legPerBin <- round(n/n_bins)

legislatorProfile_tbl$bin <- NA
for (i in 1:n_bins) {
  index <- 1:10 + (i-1)*10
  legislatorProfile_tbl$bin[index] <- i
}

## Attach bins to unassigned legislators
legislatorProfile_tbl$bin[which(is.na(legislatorProfile_tbl$bin))] <- n_bins

## Shape data
legislatorProfile_tbl <- legislatorProfile_tbl %>%
  select(full_name, chamber, party, state, bin,
         govTrack_desc, govTrack_ideology, proPub_votesAgainstParty,
         user_id, screen_name, location, description,
         statuses_count, followers_count, friends_count, favourites_count,
         n_obs_timeline, n_obs_origContent, n_obs_textOnly, earliest_status, latest_status, 
         median_favCount_OC, mean_favCount_OC, median_favCount_text, mean_favCount_text) %>%
  arrange(govTrack_ideology)

## Write data
write.csv(legislatorProfile_tbl, "Output/legislatorProfile_tbl.csv", row.names = FALSE)

## Read data
legislatorProfile_tbl <- read.csv("Output/legislatorProfile_tbl.csv", stringsAsFactors = FALSE)


filenames <- list.files("Data/Twitter/textOnly/")
# filenames <- list.files("Data/Twitter/originalContent/")
tweetList <- list()

for (i in 1:length(filenames)) {
  print(i)
  filepath <- paste0("Data/Twitter/textOnly/", filenames[i])
  tweetList[[i]] <- read.csv(filepath, stringsAsFactors = FALSE)[ , c(1:6, 12:14)]
}

## Join tables; df = {name, text, ideology} (requires dplyr)
tweets <- bind_rows(tweetList)
ideology_df <- legislatorProfile_tbl[ , c(1:7, 10, 22:25)]
df <- inner_join(tweets, ideology_df, "screen_name")

## Clean-up
rm(houseProfile_tbl, senateProfile_tbl, ideology_df, filenames, filepath, i, tweetList, tweets, index, legPerBin, n, n_bins)


## Add outlier metric
df$median_outlier <- df$favorite_count/df$median_favCount_text
df$mean_outlier <- df$favorite_count/df$mean_favCount_text

## Add character and word counts
df$n_char <- nchar(df$text)
library(ngram)
for(i in 1:nrow(df)) {
  print(i)
  df$wordcount[i] <- wordcount(df$text[i])
}

df %>%
  group_by(party) %>%
  summarise(count = n())

df %>%
  filter(party == "R") %>%
  group_by(hashtags) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  View()

df %>%
  filter(party == "D") %>%
  group_by(hashtags) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  View()


####################
## PRE-PROCESSING ##
####################


# Year tags
df$yr_2018 <- FALSE
df$yr_2018[grep("2018", df$created_at)] <- TRUE
df$yr_2017 <- FALSE
df$yr_2017[grep("2017", df$created_at)] <- TRUE
df$yr_2016 <- FALSE
df$yr_2016[grep("2016", df$created_at)] <- TRUE
df$yr_2015 <- FALSE
df$yr_2015[grep("2015", df$created_at)] <- TRUE
df$yr_2014 <- FALSE
df$yr_2014[grep("2014", df$created_at)] <- TRUE


## I need to add leading space to these words

extraneous_words <- c("congrat", "happy", "wish", "celebrat", "statement", "thank", "sign up", "signed up", "don't miss", "tune in", "newsletter")
df$extraneous <- FALSE
for (i in 1:length(extraneous_words)) {
  index <- grep(extraneous_words[i], df$text, ignore.case = TRUE)
  df$extraneous[index] <- TRUE
}

temporal_words <- c("today", "tomorrow", "tonight", "morning", "afternoon", "evening", "last night", "week", "yesterday", "starting at")
df$temporal <- FALSE
for (i in 1:length(temporal_words)) {
  index <- grep(temporal_words[i], df$text, ignore.case = TRUE)
  df$temporal[index] <- TRUE
}

position_words <- c("support", "oppos", "vote", "stop", "reject", "pass", "bill", "legislation", "want")
df$position <- FALSE
for (i in 1:length(position_words)) {
  index <- grep(position_words[i], df$text, ignore.case = TRUE)
  df$position[index] <- TRUE
}

partisan_words <- c("GOP", "republican", "democrat", "reps", "dems", "liberal", "conservative", "progressive", "libs")
df$partisan <- FALSE
for (i in 1:length(partisan_words)) {
  index <- grep(partisan_words[i], df$text, ignore.case = TRUE)
  df$partisan[index] <- TRUE
}

religious_words <- c("God", "Jesus", "pray", "relig", "church", "faith")
df$religious <- FALSE
for (i in 1:length(religious_words)) {
  index <- grep(religious_words[i], df$text, ignore.case = TRUE)
  df$religious[index] <- TRUE
}

#################
## ENVIRONMENT ##
#################
environment_words <- c("environment", "climate", "energy", "EPA ", "frack", "mineral", "forest", "tree", "water", " oil ", "wildfire", "science", "arctic", "drill", "agriculture", "farm", "scientist", "pollut")
df$environment <- FALSE
for (i in 1:length(environment_words)) {
  index <- grep(environment_words[i], df$text, ignore.case = TRUE)
  df$environment[index] <- TRUE
}

############
## HEALTH ##
############
health_words <- c("health", "healthcare", "medicaid", "medicare", "pharma", "abortion", "reproductive", "life", "choice", "nutrition", "planned parenthood")
df$health <- FALSE
for (i in 1:length(health_words)) {
  index <- grep(health_words[i], df$text, ignore.case = TRUE)
  df$health[index] <- TRUE
}

###############
## EDUCATION ##
###############
education_words <- c("educat", "school", "student", "teach", "campus", "degree", "children", "schoolchoice")
df$education <- FALSE
for (i in 1:length(education_words)) {
  index <- grep(education_words[i], df$text, ignore.case = TRUE)
  df$education[index] <- TRUE
}

################
## GOVERNMENT ##
################
government_words <- c("government", "regulation", "budget", "shutdown", "fillibuster", "housing", "deep state", "nanny state")
df$government <- FALSE
for (i in 1:length(government_words)) {
  index <- grep(government_words[i], df$text, ignore.case = TRUE)
  df$government[index] <- TRUE
}


#################
## IMMIGRATION ##
#################
immigration_words <- c("immigrat", "immigrant", "DREAM", "DACA", "wall", "border", "muslim", "mexican", "terror")
df$immigration <- FALSE
for (i in 1:length(immigration_words)) {
  index <- grep(immigration_words[i], df$text, ignore.case = TRUE)
  df$immigration[index] <- TRUE
}

##########################
## PRIVACY / TECHNOLOGY ##
##########################
technology_words <- c("technology", "NetNeutrality", "equifax", "broadband", "innovat", "data")
df$technology <- FALSE
for (i in 1:length(technology_words)) {
  index <- grep(technology_words[i], df$text, ignore.case = TRUE)
  df$technology[index] <- TRUE
}

#######################################
## THE CONSTITUTION / BILL OF RIGHTS ##
#######################################
rights_words <- c("constitution", "bill of rights", "1A", "2A", "4A", "guncontrol", "gun", "rifle", "due process", "privacy", "founders", "founding fathers")
df$rights <- FALSE
for (i in 1:length(rights_words)) {
  index <- grep(rights_words[i], df$text, ignore.case = TRUE)
  df$rights[index] <- TRUE
}


## - - -

## I need another dataframe to evaluate how widespread topic keywords are
## df = {global_keywords, rm_extraneous, rm_extraneous_temporal}

sn <- legislatorProfile_tbl$screen_name
n <- length(sn)

for (i in 1:n) {
  
  ## Progress meter
  print(paste("Progress: ", i, "/", n))

  ################
  ## PREPROCESS ##
  ################
  
  legislatorProfile_tbl$n_extraneous[i] <- df %>%
    filter(screen_name==sn[i], yr_2018==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_extraneous[i] <- df %>%
    filter(screen_name==sn[i], yr_2017==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_extraneous[i] <- df %>%
    filter(screen_name==sn[i], yr_2016==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_extraneous[i] <- df %>%
    filter(screen_name==sn[i], yr_2015==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_extraneous[i] <- df %>%
    filter(screen_name==sn[i], yr_2014==TRUE) %>%
    nrow()
  
  legislatorProfile_tbl$n_extraneous[i] <- df %>%
    filter(screen_name==sn[i], extraneous==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_temporal[i] <- df %>%
    filter(screen_name==sn[i], temporal==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_position[i] <- df %>%
    filter(screen_name==sn[i], position==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_partisan[i] <- df %>%
    filter(screen_name==sn[i], partisan==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_religious[i] <- df %>%
    filter(screen_name==sn[i], religious==TRUE) %>%
    nrow()

  ############
  ## TOPICS ##
  ############
  
  legislatorProfile_tbl$n_environment[i] <- df %>%
    filter(screen_name==sn[i], environment==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_health[i] <- df %>%
    filter(screen_name==sn[i], health==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_education[i] <- df %>%
    filter(screen_name==sn[i], education==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_government[i] <- df %>%
    filter(screen_name==sn[i], government==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_immigration[i] <- df %>%
    filter(screen_name==sn[i], immigration==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_technology[i] <- df %>%
    filter(screen_name==sn[i], technology==TRUE) %>%
    nrow()
  legislatorProfile_tbl$n_rights[i] <- df %>%
    filter(screen_name==sn[i], rights==TRUE) %>%
    nrow()
}



df %>%
  filter(environment==T | education==T | health==T | immigration==T | technology==T | rights==T | government==T) %>%
  # filter(partisan==TRUE) %>%
  filter(extraneous==FALSE, temporal==FALSE, religious==FALSE) %>%
  # filter(party == "R") %>%
  group_by(screen_name, govTrack_desc, bin) %>%
  summarise(n = n()) %>%
  group_by(bin) %>%
  summarise(sum = sum(n)) %>%
  View()


df %>%
  filter(party == "R") %>%
  filter(immigration==T) %>%
  group_by(hashtags) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  View()

df %>%
  filter(party == "R") %>%
  filter(government==T) %>%
  filter(extraneous==FALSE, temporal==FALSE) %>%
  # group_by(bin) %>%
  # summarise(n = n()) %>%
  # arrange(desc(n)) %>%
  View()

df %>%
  filter(party == "D") %>%
  filter(immigration==T) %>%
  filter(extraneous==FALSE, temporal==FALSE) %>%
  group_by(bin) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  View()

df %>%
  filter(screen_name=="RepDavidYoung") %>%
  filter(rights==T) %>%
  filter(extraneous==FALSE, temporal==FALSE) %>%
  View()

# More tables

df %>%
  filter(environment==T | education==T | health==T | immigration==T | technology==T | rights==T | government==T) %>%
  # filter(partisan==TRUE) %>%
  filter(extraneous==FALSE, temporal==FALSE, religious==FALSE) %>%
  # filter(party == "R") %>%
  group_by(screen_name, govTrack_desc, bin) %>%
  summarise(n = n()) %>%
  group_by(bin) %>%
  summarise(sum = sum(n)) %>%
  View()


df_bin01 <- df %>%
  filter(bin==1) %>%
  filter(environment==T | education==T | health==T | immigration==T | technology==T | rights==T | government==T) %>%
  filter(yr_2018==TRUE) %>%
  filter(extraneous==FALSE, temporal==FALSE, religious==FALSE) 

df_bin01 %>%
  arrange(desc(environment)) %>%
  View()

unique(df_bin01$screen_name)

View(df_bin01)

write_as_csv(df_bin01, "Output/df_bin01.csv")


df_bin53 <- df %>%
  filter(bin==53) %>%
  filter(environment==T | education==T | health==T | immigration==T | technology==T | rights==T | government==T) %>%
  filter(yr_2018==TRUE | yr_2017==TRUE) %>%
  filter(extraneous==FALSE, temporal==FALSE, religious==FALSE)


index <- grep("this", df$text, ignore.case = T)
View(df[index, ])


df %>%
  filter(wordcount < 5) %>%
  View()