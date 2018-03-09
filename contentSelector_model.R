## Congressional Tweets - Content Selector Model
## Input: tweets
## Output: WYS content
## c. Thu Mar  8 15:29:31 CST 2018

## Define Topic
topic <- "gun"
filepath <- paste0("Output/topic_dfs/", topic, "_df.csv")
df <- read.csv(filepath, stringsAsFactors = FALSE)

## Get node
bins <- 1:53
node <- sample(bins, 1)

## Get Tweet
bin_index <- which(df$bin==node)
tweet_index <- sample(bin_index, 1)

## Display content
## If media_url==true, then show image
tw <- df[tweet_index, ]

if (tw$media_url != "" && !is.na(tw$media_url))
  browseURL(tw$media_url)

tw
