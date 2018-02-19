## Congressional Tweets - Analysis Sketch
##
## c. Fri Feb 16 15:34:46 CST 2018

source("Functions/listUsers_fxn.R")

## Isolate hashtag csv filenames
ht_index <- seq(from=1, to=300, by=3)
ht_filenames <- list.files("Data/Twitter/")[ht_index]

x <- list()

for (i in 1:length(ht_filenames)) {
  x[[i]] <- read.csv(paste0("Data/Twitter/", ht_filenames[i]), stringsAsFactors = FALSE)
}

y <- bind_rows(x)

## Isolate hashtag csv filenames
tl_index <- seq(from=3, to=300, by=3)
tl_filenames <- list.files("Data/Twitter/")[tl_index]

x <- list()

for (i in 1:length(tl_filenames)) {
  index <- c(2,4,5,10:14)
  x[[i]] <- read.csv(paste0("Data/Twitter/", tl_filenames[i]), stringsAsFactors = FALSE)[ , index]
}

z <- bind_rows(x)

senateProfile_tbl <- read.csv("Output/senateProfile_tbl.csv", stringsAsFactors = FALSE)

df <- senateProfile_tbl %>%
  select(screen_name, party, state, friends_count, followers_count, statuses_count)

w <- inner_join(z, df)

index <- grep("NetNeutrality", w$hashtags)

View(w[index, ])

## Create null df; append ht, freq, screen_name, party, chamber

## Loop and combine hashtags with authorship (source account), party and chamber

tweets <- read.csv("Data/Twitter/Senate_R_InhofePress_timeline.csv", stringsAsFactors = FALSE)
tweets <- read.csv("Data/Twitter/Senate_D_ChrisVanHollen_timeline.csv", stringsAsFactors = FALSE)

tweets %>%
  filter(is_retweet == FALSE, is_quote == FALSE, reply_to_status_id == "") %>%
  View()

index <- grep("Up4Climate", tweets$hashtags)
index <- grep("climate", tweets$text, ignore.case = TRUE)


View(tweets[index, ])
