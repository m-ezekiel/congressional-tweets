## Congressional Tweets - Wikipedia Keyword Extraction

## Article links
"https://en.wikipedia.org/wiki/Environmental_policy"
"https://en.wikipedia.org/wiki/Agriculture"
"https://en.wikipedia.org/wiki/Energy_industry"
"https://en.wikipedia.org/wiki/Energy_development"

"https://en.wikipedia.org/wiki/Health_care"
"https://en.wikipedia.org/wiki/Health_care_in_the_United_States"

"https://en.wikipedia.org/wiki/Immigration"
"https://en.wikipedia.org/wiki/Immigration_to_the_United_States"

"https://en.wikipedia.org/wiki/Education"

"https://en.wikipedia.org/wiki/United_States_Bill_of_Rights"
## amendments too

# Load qdap
install.packages("qdap")
library(qdap)

# Print new_text to the console
new_text <- "Health care in the United States
From Wikipedia, the free encyclopedia
Ambox current red.svg
This article needs to be updated. Please update this article to reflect recent events or newly available information. (March 2017)
This article is part of a series on
Healthcare reform in the
United States of America
MedCorpsBC.gif
History Debate
Legislation[show]
Reforms[show]
Systems[show]
Third-party payment models[show]
Flag of the United States.svg United States portal
v t e
Health care in the United States is provided by many distinct organizations.[1] Health care facilities are largely owned and operated by private sector businesses. 58% of US community hospitals are non-profit, 21% are government owned, and 21% are for-profit.[2] According to the World Health Organization (WHO), the United States spent more on health care per capita ($9,403), and more on health care as percentage of its GDP (17.1%), than any other nation in 2014.

In 2013, 64% of health spending was paid for by the government,[3][4] and funded via programs such as Medicare, Medicaid, the Children's Health Insurance Program, and the Veterans Health Administration. People aged under 67 acquire insurance via their or a family member's employer, by purchasing health insurance on their own, or are uninsured. Health insurance for public sector employees is primarily provided by the government in its role as employer.[5]

The United States life expectancy is of 78.6 years at birth, up from 75.2 years in 1990, but only ranks 42nd among 224 nations, and 22nd out of the 35 industrialized OECD countries, down from 20th in 1990.[6][7] In 2016 and 2017 the life expectancy dropped for the first time since 1993.[8] Of 17 high-income countries studied by the National Institutes of Health, the United States in 2013, had the highest or near-highest prevalence of obesity, car accidents, infant mortality, heart and lung disease, sexually transmitted infections, adolescent pregnancies, injuries, and homicides. On average, a U.S. male can be expected to live almost four fewer years than those in the top-ranked country, though notably Americans aged 75 live longer than those who reach that age in other developed nations.[9] A 2014 survey of the healthcare systems of 11 developed countries found that the US healthcare system to be the most expensive and worst-performing in terms of health access, efficiency, and equity.[10]

Americans undergo cancer screenings at significantly higher rates than people in other developed countries, and access MRI and CT scans at the highest rate of any OECD nation.[11]

Gallup recorded that the uninsured rate among U.S. adults was 11.9% for the first quarter of 2015, continuing the decline of the uninsured rate outset by the Patient Protection and Affordable Care Act (PPACA).[12] Despite being among the top world economic powers, the US remains the sole industrialized nation in the world without universal health care coverage.[13][14]

Prohibitively high cost is the primary reason Americans give for problems accessing health care.[14] At over 27 million, higher than the entire population of Australia, the number of people without health insurance coverage in the United States is one of the primary concerns raised by advocates of health care reform. Lack of health insurance is associated with increased mortality, about sixty thousand preventable deaths per year, depending on the study.[15]

A study done at Harvard Medical School with Cambridge Health Alliance showed that nearly 45,000 annual deaths are associated with a lack of patient health insurance. The study also found that uninsured, working Americans have a risk of death about 40% higher compared to privately insured working Americans.[16]

A 2012 study for the years 2002–2008 found that about 25% of all senior citizens declared bankruptcy due to medical expenses, and 43% were forced to mortgage or sell their primary residence.[17]

In 2010, the Patient Protection and Affordable Care Act (PPACA) became law, providing for major changes in health insurance. Under the act, hospitals and primary physicians would change their practices financially, technologically, and clinically to drive better health outcomes, lower costs, and improve their methods of distribution and accessibility. The Supreme Court upheld the constitutionality of most of the law in June 2012 and affirmed insurance exchange subsidies in all states in June 2015.[18]"

# Find the 10 most frequent terms: term_count
term_count <- freq_terms(new_text, 10)

# Plot term_count
plot(term_count)