#firm_study_corruption.R

## Step 1: Determine the countries
### Orbis/BvD
### 2 Landen (voorbeeld): Brazil, Ireland

## Step 2: Determine the firms inside the country
### Use e.g. Financials > Global Standard Format > Variable (Total Assets)
### > Top 50


## Step 3: Download the firm-level data
### Make sure to include country
ireland <- readxl::read_xlsx("./Downloads/ireland.xlsx", sheet = 2) %>%
  mutate(across(everything(), ~ as.character(.x)))

brazil <- readxl::read_xlsx("./Downloads/brazil.xlsx", sheet = 2) %>%
  mutate(across(everything(), ~ as.character(.x)))

data <- dplyr::bind_rows(ireland, brazil)

## Step 4: Download the corruption data
### Source: 

library(rvest)

corruption <- read_html("https://en.wikipedia.org/wiki/Corruption_Perceptions_Index") %>%
  html_nodes("#mw-content-text > div.mw-parser-output > table:nth-child(22)") %>%
  html_table(fill = TRUE) %>%
  purrr::reduce(as.data.frame) 

corruption <- corruption %>%
  janitor::clean_names() %>%
  as_tibble() %>%
  dplyr::slice(-1) %>%
  select(-c(1,4,6,8,10,12,14,16,18,20)) %>%
  pivot_longer(-nation_or_territory) %>%
  mutate(year = as.numeric(str_extract(name, "[0-9]{4}")),
         value = as.numeric(value)) %>%
  select(-name)

## Step 5: Merge the firm-level data with the corruption data
data <- data %>%
  select(-1) %>%
  janitor::clean_names() %>%
  pivot_longer(-c(1:6)) %>%
  mutate(year = stringr::str_extract(name, "[0-9]{4}$"),
         name = stringr::str_replace(name, "[0-9]+", "")) %>%
  pivot_wider(names_from = name, values_from = value) %>%
  mutate(across(-c(1:6), ~ as.numeric(.x)))

final_data <- left_join(data, corruption,
          by = c("country" = "nation_or_territory", "year" = "year"))

  
## Step 6: Analysis

### Regression
final_data %>%
  rename(corruption = "value") %>%
  mutate(roa = p_l_before_tax_th_usd_ / fixed_assets_th_usd_,
         debtrate = long_term_debt_th_usd_/fixed_assets_th_usd_) %>%
  filter(year == 2018) %>%
  lm(formula = roa ~ debtrate + corruption + debtrate:corruption) %>%
  summary()

### Graph
final_data %>%
  rename(corruption = "value") %>%
  mutate(roa = p_l_before_tax_th_usd_ / fixed_assets_th_usd_) %>%
  filter(year == 2018) %>%
  ggplot(aes(x = log(long_term_debt_th_usd_), 
             y = log(roa), 
             group = corruption, 
             color = corruption)) +
  geom_point()

