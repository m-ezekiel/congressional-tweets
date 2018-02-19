# Anti-Vax - extractAssocations.R
# c. Thu Aug 31 15:33:05 CDT 2017


# Input: Character vector of tweet text
# Output: Character vector of associations extracted from tweet text
extractAssociations <- function(text, unique = TRUE) {
  
  # Clean text
  tweet_text <- gsub("[.,?/!:;\"()]", "", as.character(text))
  tweet_text <- gsub("'", " ", tweet_text)
  
  # Whirlpool ("@" symbol) Index 
  grep("@", tweet_text) -> wpIndex
  wpIndex
  
  # String processing to isolate "@____"
  wp_descriptions <- tweet_text[wpIndex]
  unlist(strsplit(wp_descriptions, split = " ")) -> words
  grep("@", words) -> wpTokens
  gsub("@", "", words[wpTokens]) -> associations

  if (unique == TRUE)
    associations <- sort(unique(associations))
  
  return(associations)
}