# ddp_geo_based_case_tracking

This repository contains code for the app deployed in https://pguillemi.shinyapps.io/Geo_based_case_tracking/

The app intends to create a functional geo-based tracking and monitoring tool

Interactions with map and buttons allow viewing history, update information and even add new cases to follow.

Logs are kept in a google sheet, formatting and calculations are done within the app https://docs.google.com/spreadsheets/d/1J5o5Qzh6HbLvePldUmPQvn19NK4MM8JtKUjPdsMyOE4/edit?usp=sharing

As a final note, both performance and security can be improved, this project focuses on functionalities

# App review

## Sidebar: 

Contains the "Get updated data! button, which calls the most current version of the database, incorporating all changes done while using it and resetting messages
Map explorer shows cases with colors according to their last registered state, allow selection (when a point is selected a popup appears on it)

## Tabs

Functionality is embedded within tabs as follows

### Summary

Displays information and plots regarding all cases, independet of zoom level in map.
The information it displays is total number of cases in follow up (including finished ones), and plots with number of cases by last status, by number of visits and by days elapsed since last visit.
Information in this tab is updated when "Get updated data! button is pressed

