#used the semantic.shiny library as it has a nicer feel
shinyUI(
  dashboardPage( 
    #Dashboard header
    dashboard_header(show_menu_button = T  ,titleWidth = "wide",logo_align = "center" , inverted = F, 
                     title= "Netherlands Weather App"),  
    #inactive as theres only one output
    dashboardSidebar(side = "left",disable = TRUE,
                     sidebarMenu( 
                       menuItem("Dashboard", tabName = "dash", icon = icon("info",lib = "font-awesome")) 
                     )),  
    #Body of the dashboard sourcing the UI component of the dashboard_file.R script
    dashboardBody(    
      tabItems(   
        tabItem(tabName = "dash",   
                Dashboard_file_UI("Dashboard_file-module")))
    ) 
  ))
