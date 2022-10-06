#Load libraries

library(shiny)
library(googlesheets4)
library(googledrive)
library(leaflet)
library(tidyverse)
library(lubridate)
library(DT)


# Authenticate CACHE AND E-MAIL CHANGED
gs4_auth(cache = "FANCY", email = "NOTMYEMAIL@gmail.com")

# Define UI for application

# UI ----------------------------------------------------------------------

ui <- fluidPage(
    # Application title
    titlePanel("DDP Course Project - Cases monitoring project"),
    
    # Sidebar
    sidebarLayout(
        sidebarPanel(
            fluidRow(actionButton("get_data", "Get Updated Data!")),
            fluidRow(
                h3("Explorer"),
                p("Zoom in and out to update plots and click on markers to fetch and update data")
            ),
            fluidRow(leafletOutput("map"))
        ),
        
        # Show
        mainPanel(
            tabsetPanel(
                type = "tabs",
                #summary tab panel
        
                tabPanel(
                    "Summary",
                    fluidRow(h4("General information")),
                    fluidRow(verbatimTextOutput("totalcases")),
                    fluidRow(
                        column(4, plotOutput("plot1")),
                        column(4, plotOutput("plot2")),
                        column(4, plotOutput("plot3")))),
                tabPanel(
                    "Interactive table",
                    fluidRow(h4("Interactive table"),
                             p("Only zoomed cases are shown and can be selected and highlighted in map for ease of location")),
                    fluidRow(DTOutput("data_zoom"))),
                
                #case tracking and follow up panel
                tabPanel(
                    "Case Follow up",
                    fluidRow(h4("Selected case log")),
                    fluidRow(plotOutput("plot4", height = 100)),
                    fluidRow(dataTableOutput("selected")),
                    fluidRow(h4("Update follow-up")),
                    fluidRow(
                        column(2,
                               fluidRow(h5("Selected ID")),
                               textOutput("selected_id")),
                        column(2,
                               radioButtons(
                                   "new_status",
                                   "Update status here",
                                   choices = c("ongoing", "finished", "warning")
                               )),
                        column(2,
                               textAreaInput("new_text", "Update text here")),
                        column(2,
                               dateInput("new_date", "Update date here")),
                        column(2,
                               actionButton("new_update", "Upload follow-up")),
                        column(2,
                               textOutput("message"))
                    )),
                #add new cases panel
                
                tabPanel("Add new cases",
                         fluidRow(h4("Add new cases"),
                                  p("Add new cases to follow up by clicking in map and completing required info")),
                         fluidRow(
                             column(2,
                                    textInput("create_id", "Create an unique ID")),
                             column(2,
                                    radioButtons(
                                        "create_status",
                                        "Choose status here",
                                        choices = c("ongoing", "finished", "warning")
                                    )),
                             column(2,
                                    textAreaInput("create_text", "Enter initial text here")),
                             column(2,
                                    dateInput("create_date", "Enter initial date here")),
                             column(4,
                                    fluidRow(p("New case will be created in the following coordinates")),
                                    fluidRow(
                                        column(2,
                                               tableOutput("new_coords"))),
                                    column(2,
                                           actionButton("show_me_create", "Show me!"))),
                             fluidRow(
                                 column(4,
                                        actionButton("new_create", "Create case to follow-up")),
                                 column(4,
                                        textOutput("create_message")))
                         )),
                tabPanel("Reference and help",
                         fluidRow(h4("Help"),
                         p("For help using this app, please refer to README.md 
                                    in github repository"),
                         p(a(href="https://github.com/pguillemi/ddp_geo_based_case_tracking/blob/main/README.md", "README.md")),
                                  p("App.r code is available at"),
                                  p(a(href="https://github.com/pguillemi/ddp_geo_based_case_tracking/","Github Repository")),
                                  p("Questions or comments? email me at pablo.guillemi@gmail.com")))
            )
        )
    )        
)


# SERVER ------------------------------------------------------------------


# Define server logic
server <- function(input, output, session) {
    
    #sidebar render
    df_base <- eventReactive(input$get_data, {
        base <- read_sheet(ss = "1J5o5Qzh6HbLvePldUmPQvn19NK4MM8JtKUjPdsMyOE4",
                   sheet = "ddp_log")
        base <- base %>% 
            mutate(
                visit = as.Date(visit),
                status = as.factor(status),
                id_internal = 1:nrow(base)
            )
        base
        })
    #clear messages in ui
    observeEvent(input$get_data,{
        output$message <- NULL
        output$create_message <- NULL
        
    }
                 )
    
    df <- reactive({
        last_ev <- df_base() %>% 
            group_by(id) %>% 
            filter(id_internal == max(id_internal)) %>% 
            filter(1:n() == 1) %>% 
            ungroup() %>% 
            mutate(
                days_since_last_update = as.numeric(today()-as.Date(visit))
            ) %>% 
            select(-id_internal)
        visit_count <- df_base() %>% 
            group_by(id) %>% 
            summarise(
                visit_count = n()
            )
        last_ev <- left_join(last_ev, visit_count)
        last_ev
    })
    
    finished <- reactive({
        df() %>% 
            filter(status == "finished")
    })
    
    ongoing <- reactive({
        df() %>% 
            filter(status == "ongoing")
    })
    
    warn <- reactive({
        df() %>% 
            filter(status == "warning")
    })
    
    output$map <- renderLeaflet({ 
        leaflet() %>%
            addProviderTiles(providers$Esri.WorldTopoMap) %>% 
            addCircleMarkers(lng = ongoing()$lon, 
                             lat = ongoing()$lat, 
                             popup = str_c(ongoing()$id,ongoing()$text, sep = " - "),
                             layerId = ongoing()$id,
                             opacity = 0.8,
                             color = "blue") %>% 
            addCircleMarkers(lng = warn()$lon, 
                             lat = warn()$lat, 
                             popup = str_c(warn()$id,warn()$text, sep = " - "),
                             layerId = warn()$id,
                             opacity = 0.8,
                             color = "red") %>% 
            addCircleMarkers(lng = finished()$lon, 
                             lat = finished()$lat, 
                             popup = str_c(finished()$id,finished()$text, sep = " - "),
                             layerId = finished()$id,
                             opacity = 0.8,
                             color = "green")
        
    })
    #summary panel
    
    plot1 <- reactive({
        ggplot(data = df(), aes(x = status, fill = status)) +
            geom_bar()+
            coord_flip()+
            scale_fill_manual(values = c("ongoing" = "skyblue3",
                                          "warning"="indianred3",
                                          "finished"="seagreen3"))+
            ggtitle("Number of cases per current status")+
            labs(y = "Number of cases", x = "Current status")

        })
    
    output$plot1 <- renderPlot(plot1())
    
    plot2 <- reactive({
        ggplot(data = df(), aes(x = visit_count, fill = status)) +
            geom_bar()+
            scale_fill_manual(values = c("ongoing" = "skyblue3",
                                         "warning"="indianred3",
                                         "finished"="seagreen3"))+
            ggtitle("Number of cases per case status updates")+
            labs(y = "Number of cases", x = "Number of case status updates")
        
        
    })
    
    output$plot2 <- renderPlot(plot2())
    
    plot3 <- reactive({
        ggplot(data = df(), aes(x = days_since_last_update, fill = status)) +
            geom_bar()+
            scale_fill_manual(values = c("ongoing" = "skyblue3",
                                         "warning"="indianred3",
                                         "finished"="seagreen3"))+
            ggtitle("Number of cases per days since last update")+
            labs(y = "Number of cases", x = "Days elapsed since last update")
        
    })
    
    output$plot3 <- renderPlot(plot3())
    
    output$totalcases <- renderPrint(str_c("Total cases in follow up: ",nrow(df()), sep = ""))
    
    #interactive table
    data_in_map <-  eventReactive(input$map_bounds,
                                {   zoomed <- data.frame(
                                    east = input$map_bounds$east,
                                    west = input$map_bounds$west,
                                    south = input$map_bounds$south,
                                    north = input$map_bounds$north)
                                    
                                    data <- df() %>%
                                        filter(lat >= zoomed$south) %>% 
                                        filter(lat <= zoomed$north) %>% 
                                        filter(lon <= zoomed$east) %>% 
                                        filter(lon >= zoomed$west)
                                    data
                                        
                                })
    
    output$data_zoom <- renderDT(data_in_map()[,c(1:4,7:8)], selection = "single")
    
    observeEvent(input$data_zoom_rows_selected,{
        i <- input$data_zoom_rows_selected
        map_h <- data_in_map()[i,]
        leafletProxy("map") %>% 
            clearShapes() %>% 
            addCircles(lng = map_h$lon, 
                             lat = map_h$lat,
                             layerId = map_h$id,
                             color = "purple",
                       opacity = 1)
        })             
    
    
#information for case follow up panel    
    clicked <- eventReactive(input$map_marker_click, {
        id_1 <- input$map_marker_click$id
        selected <- df_base() %>% 
            filter(id == id_1) %>% 
            select(-id_internal) %>% 
            mutate(
                days_ago = as.numeric(today()-as.Date(visit))
            ) %>% 
            arrange(days_ago)
        selected
    })
    
    output$selected <- renderDataTable(clicked())
    output$selected_id <- renderText(clicked()$id[[1]])
    
    observeEvent(input$selected_rows_selected,{
        i <- input$selected_rows_selected
        map_h <- clicked()[i,]
        leafletProxy("map") %>% 
            clearShapes() %>% 
            addCircles(lng = map_h$lon, 
                       lat = map_h$lat,
                       layerId = map_h$id,
                       color = "purple",
                       opacity = 1)
    })
    
    observeEvent(input$new_update,{
        
        if(input$new_text == ""){
            output$message <- renderPrint("Not able to update - a selected marker and new text is required")           
        } else {
            upload_data <- data.frame(
                id = clicked()$id[[1]],
                status = input$new_status,
                visit = input$new_date,
                text = input$new_text,
                lat = clicked()$lat[[1]],
                lon = clicked()$lon[[1]]
            )
            
            sheet_append(
                ss = "1J5o5Qzh6HbLvePldUmPQvn19NK4MM8JtKUjPdsMyOE4",
                data = upload_data,
                sheet = "ddp_log")
            
            updateDateInput(inputId = "new_date", value = today())
            updateRadioButtons(inputId = "new_status")
            updateTextAreaInput(inputId = "new_text", value = "")
            
            output$message <- renderPrint("update successful - press Get Data! to see updates in map and tables")
        }
    })
    
    plot4 <- reactive({
        ggplot(data = clicked(), aes(x = visit, fill = status)) +
            geom_bar(width = 0.5)+
            scale_fill_manual(values = c("ongoing" = "skyblue3",
                                         "warning"="indianred3",
                                         "finished"="seagreen3"))+
            labs(x = "Date", y = "Updates")
    })
    
    output$plot4 <- renderPlot(plot4(),  height = 100)
    
    
    #information for add new case panel
    new_case_coords <- eventReactive(input$map_click,{
        lng <- input$map_click$lng
        lat <- input$map_click$lat
        coords <- data.frame(
            lon = lng,
            lat = lat)
        coords
    })
    
    output$new_coords <- renderTable(new_case_coords())
    
    observeEvent(input$show_me_create,{
            leafletProxy("map") %>%  
            addMarkers(lng = new_case_coords()$lon, lat = new_case_coords()$lat, layerId = "NewPoint")
    })
    
    observeEvent(input$new_create,{
        
        if(input$create_text == ""){
            output$create_message <- renderPrint("Not able to update - a new text is required")           
        } else if(input$create_id %in% df()$id) {
            output$create_message <- renderPrint("The Case ID is taken, please select a different ID")
        }else{
            upload_create <- data.frame(
                id = input$create_id,
                status = input$create_status,
                visit = as.Date(input$create_date),
                text = input$create_text,
                lat = new_case_coords()$lat[[1]],
                lon = new_case_coords()$lon[[1]]
            )
            
            sheet_append(
                ss = "1J5o5Qzh6HbLvePldUmPQvn19NK4MM8JtKUjPdsMyOE4",
                data = upload_create,
                sheet = "ddp_log")
            
            updateDateInput(inputId = "create_date", value = today())
            updateRadioButtons(inputId = "create_status")
            updateTextAreaInput(inputId = "create_text", value = "")
            
            output$create_message <- renderPrint("Event Creation successful - press Get Data! to see updates in map and tables")
        }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
