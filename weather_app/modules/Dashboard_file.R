#UI component
Dashboard_file_UI <- function(id) {
  ns <- NS(id)
  tagList( 
    fluidRow(
      #heading box
      value_box("Titel",htmlOutput(ns("value_5")),color = "orange", 
                width = 16, size = "tiny")
    ), 
    column(width = 12,
           #training indicator component
           box(title="sporten/niet sporten indicator", color = "green", width = 12,    
               rHandsontableOutput(ns("Jogging_Table")) 
           ) 
    ), 
    column(width = 4,
           box(title = "Controlepaneel", color = "purple", width =4,
               collapsible = T,  
               #allows user to upload a calender in the working directory
               file_input(ns("fileDrive"), "",placeholder = "Upload a File ..."
                          ,type = "small",width = "150px") ,br(),
               #allows user to remove and update calender in working directory
               actionButton(ns("removeBtn"), "Delete file", icon("red trash")),br(),
               #date range selector
               tags$div(tags$div(HTML("<b>Datum vanaf :</b> ")),
                        date_input(ns("date_from"), value =  Sys.Date(), 
                                   style = "width: 70%;")),
               br(),
               tags$div(tags$div(HTML("<b>Datum tot :</b> ")),
                        date_input(ns("date_to"), value = Sys.Date()+2, 
                                   style = "width: 70%;")) 
           )
    ),
    column(width = 16,
           box(title="Kaart", color = "green", width = 16,    
               leafletOutput(ns("my_map"))
           ) 
    )
    
  )
}

#Server compoent
Dashboard_file <- function(input, output, session, pool) { 
  #date selector
  starting_date<-reactive({input$date_from}) 
  ending_date<-reactive({input$date_to})
  #upload file
  observe({
    if (is.null(input$fileDrive)) return()
    file.copy(input$fileDrive$datapath, 
              file.path(paste(getwd(),"/data_folder_sheq",sep = ""),
                        input$fileDrive$name), overwrite = TRUE) 
  }) 
  
  #delete files
  observeEvent(input$removeBtn,{
    ns <- session$ns
    create_modal(modal( 
      id="modal-pop-up",
      tagList(
        selectInput(ns("deletefilename"), 
                    label = "Delete a file", 
                    choices = list.files(paste(getwd(),"/data_folder_sheq",sep = ""), 
                                         include.dirs = F, full.names = T, recursive = T))
        #use the server directory to source the files
      ),  
      footer = tagList(actionButton(ns("confirmDelete"), "Delete",icon("red trash")),
                       actionButton(ns("cancelAction"), "Cancel"),
      )
    ))
  })
  
  #delete confirmation action
  observeEvent(input$confirmDelete, {
    req(input$deletefilename)
    file.remove(input$deletefilename)
    removeModal() 
  })
  
  observeEvent(input$cancelAction, {
    hide_modal(id="modal-pop-up")
  })
  #check if theres calender file in the calender folder
  if(sapply(paste(getwd(),"/calendr_folder",sep = ""),
            function(dir){length(list.files(dir,pattern='xls'))})>=1){ 
    #source data
    MyCalendr <- read_excel("calendr_folder/MyCalendr.xls")
    
  output$Jogging_Table <- renderRHandsontable({ 
    
    # get forecast
    forecast <- get_forecast("Netherlands", units = "metric") %>%
      owmr_as_tibble()
    Weather.data = data.frame(forecast)
    
    
    #subset data by Date, temp and weather description
    
    Weather.data = Weather.data[ , c(1, 2, 9)]
    rhandsontable(Weather.data)
    #rename columns
    colnames(Weather.data) <- c( "Date (3hr interval)","Temperature","Weather Description")  
    #Weather.data[Weather.data$`Date (3hr interval)`>=Sys.Date() &Weather.data$`Date (3hr interval)`<=Sys.Date()+1,]
    
    #getwd()
   
    colnames(MyCalendr) <- c( "Date (3hr interval)","activiteit")  
    
    
    
    #Joining by: Date (3hr interval)
    merged.data = join(Weather.data, MyCalendr,
                       type = "inner")
    merged.data [is.na(merged.data )] <- ""
    
    #show good time to jog if theres no activity on the calender and the tempterature if >15
    merged.data["jogging decision"] = ifelse(merged.data$Temperature>15 & 
                                               merged.data$activiteit =="","joggen","niet joggen")
    merged.data 
    colnames(merged.data) <- c( "Datum (3hr interval)","temperatuur-","Weerbeschrijving","Activiteit",
                                "Jogging beslissing")  
    
    
    rhandsontable(merged.data[merged.data$`Datum (3hr interval)`>=starting_date()[1] &merged.data$`Datum (3hr interval)`<=ending_date()[1],]
                  ,
                  readOnly = TRUE,search = TRUE)%>%
      hot_cols(columnSorting = TRUE,highlightCol = TRUE, highlightRow = TRUE,
               manualColumnResize = T)%>%
      hot_cols(fixedColumnsLeft = 1) %>% 
      hot_cols(renderer = " 
      function (instance, td, row, col, prop, value, cellProperties) {
        Handsontable.renderers.TextRenderer.apply(this, arguments); 
        if((value < 10 && col==1)) {td.style.background = 'pink';} 
        if((value > 15 && col==1)) {td.style.background = 'lightgreen';}  
        }")%>% 
      hot_context_menu(
        customOpts = list(
          search = list(name = "Search",
                        callback = htmlwidgets::JS(
                          "function (key, options) {
              var srch = prompt('Search criteria');
              this.search.query(srch);
              this.render();
              }"))))%>%hot_table(highlightCol = TRUE, highlightRow = TRUE)%>% 
      hot_context_menu(
        customOpts = list(
          csv = list(name = "Download to CSV",
                     callback = htmlwidgets::JS(
                       "function (key, options) {
             var csv = csvString(this, sep=',', dec='.');
             var link = document.createElement('a');
             link.setAttribute('href', 'data:text/plain;charset=utf-8,' +
             encodeURIComponent(csv));
             link.setAttribute('download', 'data.csv');
             document.body.appendChild(link);
             link.click();
             document.body.removeChild(link);}")))) %>%
      hot_cell(1, 3, "") 
  })
  
  output$my_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addMarkers(lng=4.9041, lat=52.3676, popup="Amsterdam")
  })
  
  #Application heading
  output$value_5 <- renderText({ 
    font<-'blue'
    formatedFont_1 <- sprintf('<font color="%s">%s</font>',
                              font,"Nederland Weer App") 
    return(formatedFont_1) 
  })
  }else{
    #do nothing if theres no data
  }
} 