# firm_study_pol_con

## Step 1: Get the firms you want
### Here: Bureau van Dijk/Orbis

## Step 2: Find the Board members
### Here: Bureau van Dijk/Orbis
library(tidyverse)

directors <- readxl::read_xlsx("./Downloads/directors.xlsx", sheet = 2)

directors <- directors %>%
  select(-1) %>%
  janitor::clean_names() %>%
  tidyr::fill(c(1:61))


### select only the data without directors
firm_data <- directors %>%
  select(-c(2:5, 9:11)) %>%
  distinct(ticker_symbol, .keep_all = TRUE) %>%
  mutate(across(everything(), ~ as.character(.x))) %>%
  pivot_longer(fixed_assets_th_usd_2020:cash_flow_operating_revenue_percent_2016) %>%
  mutate(year = str_extract(name, "[0-9]{4}$")) %>%
  mutate(name = str_replace(name, "[0-9]+", "")) %>%
  pivot_wider(names_from = name, values_from = value)

### clean the data with directors
directors <- directors %>%
  select(c(1, 6:11)) %>%
  mutate(full_name = paste(dm_first_name, dm_last_name))
  
## Step 3: Find the Politicians
### Here: Bundestag

library(rvest)

## Data frame
bundestag <- read_html("https://en.wikipedia.org/wiki/List_of_members_of_the_17th_Bundestag") %>%
  html_nodes("table.wikitable:nth-child(8)") %>%
  html_table(fill = TRUE) %>%
  purrr::reduce(as.data.frame)


## clean the data
bundestag <- bundestag %>%
  janitor::clean_names() %>%
  select(name) %>%
  separate(name, into = c("last", "first"), sep = ",") %>%
  mutate(first_last = paste(first, last)) %>%
  select(first_last)

## Step 4: Match the politicians to the board members
library(stringdist)

directors <- directors %>%
  mutate(first_last = paste(dm_first_name, dm_last_name)) 

directors <- directors %>%
  mutate(inpolitics = if_else(stringdist::amatch(first_last, bundestag$first_last, 
                                                 maxDist = 3) != 0,
                              "yes", 
                              "no")
  )

## Step 5: Count political connections
no_of_pol_con_per_firm <- directors %>%
  group_by(isin_number) %>%
  distinct(first_last, .keep_all = TRUE) %>%
  summarize(howmany = sum(inpolitics == "yes",
                          na.rm = TRUE))

## Step 6: Merge with firms

merged_data <- left_join(firm_data, no_of_pol_con_per_firm, 
                         by = c("isin_number" = "isin_number"))

## And we can chose to further clean it, because the ISIN's change over time:

final_data <- merged_data %>%
  group_by(company_name_latin_alphabet, year) %>%
  mutate(howmany = sum(howmany, na.rm = TRUE)) %>%
  mutate(across(c(4:14), ~ as.numeric(.x)))

## Step 7: Analysis with Control variables for firm
final_data %>%
  filter(year == 2020) %>%
  ggplot(aes(x = howmany)) + geom_bar() + 
  xlab("How many political connections?") +
  ylab("Frequency (no. of companies)")


