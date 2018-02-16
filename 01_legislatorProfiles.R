## Congressional Tweets - Legislator Profiles
## Output: senateProfile_URLs, houseProfile_URLs
## c. Mon Jan  8 00:17:54 CST 2018

#########################
## SENATE PROFILE URLS ##
#########################

## ProPublica database of 115th U.S. Senate members
raw_html <- readLines("https://projects.propublica.org/represent/members/115/senate")

## Extract html line numbers for links to legislator URLS
index <- seq(from=346, to=1435, by=11)
raw_html_URLs <- trimws(raw_html[index])

names <- trimws(gsub("<.*?>", "", raw_html_URLs))

## Parse html to extract URLs
rm_span <- gsub("<span.*?a>", "", raw_html_URLs)
rm_a <- gsub("<a href=\"", "", rm_span)
rm_tag <- gsub("\\\">", "", rm_a)

profile_URLs <- paste0("https://projects.propublica.org", rm_tag)

## Write data
senateProfile_URLs <- data.frame(name = names, propublica_url = profile_URLs, 
                                 stringsAsFactors = FALSE)
write.csv(senateProfile_URLs, "Output/senateProfile_URLs.csv", row.names = FALSE)