# event study political connections
library(tidyverse); library(lubridate); library(readxl)

# Step 1: get S&P 500 constituents list
## https://github.com/Robot-Wealth/r-quant-recipes/tree/master/historical-spx-constituents
s_p500 <- readRDS("./Downloads/historicalspx.RDS")

# Step 2: get S&P 500 around each election

## One election: November 6, 2012,

elections2012 <- s_p500 %>%
  mutate(absdist = abs(Date - ymd("2012-11-06"))) %>%
  filter(absdist == min(absdist))


# Step 3: do the event study and get the event study data
# On WRDS: Event study tool
## Write the file to .txt so that WRDS accepts the input
library(readr)


elections2012 %>%
  mutate(date = "20121106") %>%
  select(Ticker, date) %>%
  readr::write_delim("./Downloads/elections2012ticker",
                   col_names = FALSE)

## Select the following variables: MODEL, EVTDATE, EVTTIME, ABRET, CAR
## In data output options, select .csv
## Download the _last_ file

# Step 4: Retrieve the political connections from Wikipedia (or elsewhere)
library(rvest)

politicians_congress_111 <- read_html("https://en.wikipedia.org/wiki/111th_United_States_Congress") %>%
  html_nodes("#mw-content-text > div.mw-parser-output > div:nth-child(81) table tbody tr td  li") %>%
  html_text() %>%
  as.data.frame()

## Clean the dataset

### You can do it using Find and replace in Excel 
### or use this code:

politicians_congress_111 <- politicians_congress_111 %>%
  rename("name" = ".") %>%
  mutate(name = str_replace(name, "(.+)\\.", "")) %>%
  separate(name, into = c("name", "party"), sep = "\\(") %>%
  mutate(name = str_trim(name), party = sub("\\).*", "", party))


# Step 5: Retrieve the directors for each of the firms in the S&P 500
## On WRDS:
## BoardEx/Committee Details/Board and Director Committees
## Enter: Company Name, Company ID, Individual/Director ID/Individual Director Name
## Output: .csv
boardmembers_2012 <- readr::read_csv("./Downloads/board_members.csv") %>%
  janitor::clean_names() %>%
  mutate(annual_report_date = str_extract(annual_report_date, "[0-9]{4}")) %>%
  filter(annual_report_date == "2012")

## Also possible: BvD/Orbis

# Step 6: Match the directors to the politicians

matches <- boardmembers_2012 %>%
  group_by(ticker) %>%
  distinct(director_name, .keep_all = TRUE) %>%
  mutate(polcon = politicians_congress_111$name[stringdist::amatch(
      director_name, politicians_congress_111$name)])

## Merge to get the party, and count the connections per firm

polconfirm <- left_join(matches, politicians_congress_111,
          by = c("polcon" = "name")) %>%
  group_by(ticker) %>%
  summarize(polcon_rep = sum(party == "R", na.rm = TRUE),
         polcon_dem = sum(party == "D", na.rm = TRUE)) 

# Step 7: Match the event study data to the firm data
## Import the event study data
## Calculate the cumulative abnormal returns
event_study <- readr::read_csv("./Downloads/event_study_data_2012.csv")


## Merge the event study with the polcon dataset

event_study <- event_study %>%
  left_join(polconfirm)

## Step 8: Analysis:
### Make a graph of the CAR's
###Calculate the confidence intervals around the mean cars

### Graph 1: Entire sample
dataforgraph <- event_study %>%
  ungroup() %>%
  group_by(evttime) %>%
  summarize(nobs = n(), 
            aar = mean(abret, na.rm = TRUE), 
            var = var(abret)) %>%
  mutate(acar = cumsum(aar), 
         avar = cumsum(var))

dataforgraph %>%
  ggplot(aes(x = evttime)) + geom_line(aes(y = acar)) +
  geom_line(aes(y = acar - 1.96*sqrt(avar)/sqrt(nobs)), linetype = "dashed") +
  geom_line(aes(y = acar + 1.96*sqrt(avar)/sqrt(nobs)), linetype = "dashed")

### Graph 2: Politically connected vs not
dataforgraph2 <- event_study %>%
  mutate(polcon = if_else(polcon_rep == 1 | polcon_dem == 1, "1", "0")) %>%
  ungroup() %>%
  group_by(evttime, polcon) %>%
  summarize(nobs = n(), 
            aar = mean(abret, na.rm = TRUE), 
            var = var(abret)) %>%
  mutate(acar = cumsum(aar), 
         avar = cumsum(var)) %>%
  na.omit()

dataforgraph2 %>%
  ggplot(aes(x = evttime, 
             group = polcon, 
             color = polcon)) + geom_line(aes(y = acar)) +
  geom_line(aes(y = acar - 1.96*sqrt(avar)/sqrt(nobs)), linetype = "dashed") +
  geom_line(aes(y = acar + 1.96*sqrt(avar)/sqrt(nobs)), linetype = "dashed")
