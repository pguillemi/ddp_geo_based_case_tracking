# ddp_geo_based_case_tracking

This repository contains code for the app deployed in https://pguillemi.shinyapps.io/Geo_based_case_tracking/

The app intends to create a functional geo-based tracking and monitoring tool

Interactions with map and buttons allow viewing history, update information and even add new cases to follow.

Logs are kept in a google sheet, formatting and calculations are done within the app https://docs.google.com/spreadsheets/d/1J5o5Qzh6HbLvePldUmPQvn19NK4MM8JtKUjPdsMyOE4/edit?usp=sharing

As a final note, both performance and security can be improved in a production environment, this project focuses on displaying functionalities

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

### Interactive table

This tabs interacts with the map in two ways.
First, cases shown in the table are relative to cases displayed in map, and dinamically updated. This allows to zoom and focus on certain regions.
Secondly, if a line is clicked in the table, a small purple dot appears in the marker in the map, so as to identify the case. This table also allows search and changing orden

### Case follow up

This tab also interacts with the map.
Cases are selected by clicking in the map. This brings up popup in the map, and renders the following in this tab

* A plot showing updates in time for that particular case -identified by its unique ID
* A table displaying all follow up actions, that also highlights dots in map when clicked for better identification

Then, there is a series of input boxes that add a new "visit" or traking update to the selected ID. There is some basic data validation in the background, basically preventing uploading blank updates, and clearing text boxes after a succesful upload, which in turn also prevents from multiple clicking.
Update data is stored in that moment in the associated googlesheets log, and is brought back to the app when the Get updated Data! Button is clicked.

### Add new cases
This tab interacts with the map observing the map click event (not the marker click).
The Show me! button prints a marker in the map where the new case will be.
Input boxes have to be filled with the required information.
Some small validation is done, basically checking that the ID has not been taken yet, plus that some text is uploaded and clearing text boxes after a successful upload, which in turn also prevents from multiple clicking.
Point creatiion is stored in that moment in the associated googlesheets log, and is brought back to the app when the Get updated Data! Button is clicked.

### Reference and help

This tabs provides link to this repository, which also contains code




