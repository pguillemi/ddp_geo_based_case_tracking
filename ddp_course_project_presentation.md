Coursera DDP - Course project
Geo-based tracking and monitoring tool
========================================================
author: Pablo Guillemi
date: 2022-10-06
autosize: true

The idea
========================================================

This app aims to provide straightforward answers to some very important aspects of case monitoring (who could be patients, customers, place-specific situations).

- Where are they?
- what is their status?
- Can I update real time information regarding my current actions?


Main parts of the app
========================================================

- A leaflet map, that shows cases and can interact in several ways with displayed information
- A set of tabs that
  - Show a summary regarding all the cases
  - Update interactively with map zoom, identifying and highlighting cases
  - Show case history and allow to upload updates IN REAL TIME
  - Can create in spot new cases to follow up
- Last but not least: an online log that keeps track of all changes
  
Some current information from the app
========================================================
How many cases are currently being followed up?

The following information comes from embedded R code that reads information directly from app log: https://docs.google.com/spreadsheets/d/1J5o5Qzh6HbLvePldUmPQvn19NK4MM8JtKUjPdsMyOE4/edit#gid=0




```
# A tibble: 1 × 3
  date_of_report number_of_cases monitoring_events
  <date>                   <int>             <int>
1 2022-10-06                   9                23
```

I want to try it!!
========================================================
App is at
https://pguillemi.shinyapps.io/Geo_based_case_tracking/

github repository
https://github.com/pguillemi/ddp_geo_based_case_tracking
  
  
## _THANK YOU!_
