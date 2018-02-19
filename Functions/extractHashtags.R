# Anti-Vax - extractHashtags.R
# c. Thu Aug 31 15:33:05 CDT 2017

# Input: Character vector of tweet text
# Output: Character vector of hashtags extracted from tweet text
extractHashtags <- function(text, unique = TRUE) {
  
  # Clean text
  tweet_text <- gsub("[.,?/!:;\"()]", "", as.character(text))
  tweet_text <- gsub("'", " ", tweet_text)
  
  # Whirlpool ("@" symbol) Index 
  grep("#", tweet_text) -> htIndex
  htIndex
  
  # String processing to isolate "@____"
  ht_descriptions <- tweet_text[htIndex]
  unlist(strsplit(ht_descriptions, split = " ")) -> words
  grep("#", words) -> htTokens
  words[htTokens] -> hashtags
  
  if (unique == TRUE)
    hashtags <- sort(unique(hashtags))
  
  return(hashtags)
}