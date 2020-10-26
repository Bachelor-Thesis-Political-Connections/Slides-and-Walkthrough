## Introduction

Welcome! In this repository, you can find the first lecture's slides, as well as a short description of possible themes below. 

## Themes

There are many interesting questions within the political connections literature. There seems, however, to be a pattern in the questions researchers are tackling. 
Some of those questions seem appropriate for an audience of students aiming to write a BSc thesis, and can be found below:

| Kind of study | Example: |
| -------- | ----------- |
| Event studies | Effect of state visits on stock prices |
| Cross-country studies | Effect of relations between big business and politicians on economic growth |
| Firm-level studies | Effect of a (former) politician on the Board of Directors on firm performance |

## Event studies

Event studies are usually aiming to explain **abnormal returns** of stock prices around an important event that supposedly have an impact on firms' financial results. More often than not, it starts to get interesting when, for some reason, events are hypothesized to have **differential** impacts on different firms - that allows for a wide variety of hypotheses to be tested. 

A few example questions that can be answered using event studies can be:
- What is the influence on value of connections to the president/prime minister of a country? 
- When do political connections expire? Do firms with which politicians were affiliated in the past still benefit from their connections?
- What is the value of having connections to a minister?
- What is the influence of CEO's on their company's value?
- Do foreign companies benefit from coup d'états in countries in which they are active?

And a seminal study about the theory and practice underlying event studies is provided here:

 > MacKinlay, A. C. (1997). Event studies in economics and finance. _Journal of Economic Literature_, 35(1), 13-39.

### Data sources

Event studies are usually performed using data from the [WRDS](https://wrds-www.wharton.upenn.edu/) database. However, this is by no means necessary. There are many databases, and even R and Python packages/libraries, that give you fairly easy access to stock prices over a particular period/in a particular index. In this regard, there will be some tutorials available on this repository. 

## Cross-country studies

Cross-country studies compare countries, or countries over time, and (usually) want to say something about their economic or societal development. 
In this theme, it could be relevant to think about how the relationships between big business and politics affect policy making, and maybe ultimately, economic growth of an entire country.

A few example questions to get your thinking started: 
- Usually, countries with a higher corruption index are associated with their politics being captured by powerful business interests. Why is this so? 
- Are there also reasons why intimate connections between politics and business could be beneficial? 
- Are there more ways that businesses' links with politics could impact a country, rather than only influencing economic growth?
- Could it be that politicians influence firms' behavior, rather than firms influencing politicians' behavior? What aggregate (macroeconomic) effects would that have?
- What could be the consequences of variation in regulation of politicians? Think about salary, or mandatory asset declarations of politicians, or behavior of state-owned companies?
- Could a country's institutions and regulation of politicians affect who becomes politically active?

### Data sources

Some often-used data sources are the following:

- [The World Bank](https://data.worldbank.org/) (also accessible through API using Python libraries or R packages)
- [The OECD](https://data.oecd.org/)
- [Transparency International Corruption Index](https://www.transparency.org/en/cpi#)
- [EDGAR](https://www.sec.gov/edgar/searchedgar/companysearch.html)
- Websites of national parliaments
- [Our World In Data](https://ourworldindata.org/)
- (Eurostat)[https://ec.europa.eu/eurostat]
- [World Values Survey](http://www.worldvaluessurvey.org/wvs.jsp)

Also: try to read many articles! There is hardly any empirical study that does not list its data sources!

## Firm-level studies

Finally, there are firm-level studies.

### Data sources

Firm-level studies usually use data from Compustat IQ, available on WRDS, which has excellent accounting data, but it slightly biased towards US firms. [ORBIS van Dijk](https://orbis-bvdinfo-com.eur.idm.oclc.org/) has a more international database, and also has a wide variety of variables available. 

