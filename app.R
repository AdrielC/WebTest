# https://rstudio.github.io/reticulate/reference/conda-tools.html

library(reticulate)
library(purrr)
library(tibble)
library(tidyr)
library(shiny)
library(ggplot2)
library(ggthemes)
library(stringr)
library(shinymaterial)
library(flexdashboard)
library(dplyr)
library(shinyWidgets)


# Python Setup ------------------------------------------------------------

if(!("overstockShiny" %in% conda_list(conda = "auto")$name)){
  conda_create("overstockShiny", packages = c("python",
                                              "pandas",
                                              "selenium",
                                              "datetime",
                                              "unicodecsv"), conda = "auto")
  }

tryCatch(use_condaenv("overstockShiny", conda = "auto", required = FALSE),
         error = function(e)stop("Conda environment not activated: Failure to start"))

source_python(file = "test.py")


# Data for UI inputs ------------------------------------------------------

## Default URL to fill the text box with 
defaultURL <- "https://www.overstock.com/search?keywords=couch&SearchType=Header"

## Viewport definitions
viewports <- tibble(iPhone4s = c(320, 480),
                    iPhone5 = c(320, 568),
                    iPhone6 = c(375, 667),
                    iPhone6Plus = c(414, 736),
                    iPad2 = c(1024, 768),
                    SamsungGalaxy = c(360, 640),
                    Macbook13 = c(1440, 900),
                    iMac27 = c(2560, 1440))

## Available browser options in Selenium 
browsers <- c("Firefox",
              "Internet Explorer",
              "Safari",
              "Opera",
              "Chrome")

# Dashboard Layout
ui <- material_page(
  title = 'Overstock Site Impression Testing',
  nav_bar_color = 'red',
  
  material_parallax(
    image_source =
      "https://www.sadevusa.com/wp-content/uploads/2017/12/2016_USA_Peace_Coliseum_building_overstock_headquarter_R1006-2.jpg"
  ),
  
  tags$br(),
  
  material_row(
    # Inputs
    material_column(
      width = 4,
      material_card(
        title = "Scroll Page URL",
        material_text_box(
          "url",
          "URL"
        )
      ),
      material_card(
        title = "Scroll Options",
        material_slider(
          'scroll',
          'Speed: slow to fast',
          1, 10, 5,
          "#ef5350"
        ),
        material_switch(
          "human",
          "Human scroll mode",
          "Off",
          "On",
          initial_value = TRUE,
          color = "#ef5350"
        )
      ),
      material_card(
        title = "WebDriver Options",
        material_dropdown(
          input_id = "viewport",
          label = "Select Viewport Size",
          choices = names(viewports)
        ),
        material_dropdown(
          input_id = "browser",
          label = "Select Browser",
          choices = browsers
        )
      ),
      material_modal('info',
                     'About',
                     "lmao",
                     button_icon = 'info', 
                     button_color = 'blue-grey lighten-2'
      )
    ),
    
    # Map and Cycle
    material_column(
      width = 3.2,
      material_card(
        title = "Simulated Scroll Speed",
        plotOutput('cycle')
      ),
      material_button(
        input_id = "run",
        label = "Run Scroll Test",
        depth = 5, 
        color = "deep-orange accent-4"
      )
    ),
    
    # Results and Evaluation
    material_column(
      width = 3,
      material_row(
        material_card(
          title = "Cookie ID",
          icon(''),
          htmlOutput('baseline')
        ),
        material_card(
          title = 'Fired Tags',
          icon(''),
          htmlOutput('hybrid')
        ),
        material_card(
          title  = "Impression Evaluation",
          material_radio_button(
            input_id = "impression",
            label = "record impression or not?",
            choices = c("Yes", "No"),
            color = "#ef5350"
          )
        ),
        material_card(
          title  = "Upload Report",
          material_text_box(
            input_id = "email",
            label = "Email for report",
            color = "deep-orange accent-4"
          ),
          material_button(
            input_id = "sendReport",
            label = "Send Report",
            depth = 5, 
            color = "deep-orange accent-4"
          )
        )
      )
    )
  )
)

# Dashboard Logic
server <- function(input, output, session) {
  update_material_text_box(session, 'url', defaultURL)
  update_material_dropdown(session, input_id = "browser", value = "Chrome")
  update_material_dropdown(session, input_id = "viewport", value = "Macbook13")
  
  url <- reactive({input$url})
  viewport <- reactive({input$viewport})
  browser <- reactive({input$browser})
  
  observeEvent(input$sendReport, {
    sendSweetAlert(session = session, 
                   title = "Success", 
                   text = paste0("Report will be sent to ", input$email),
                   type = "success",
                   btn_labels = c("Cool..."),
                   closeOnClickOutside = TRUE)
  },
  ignoreInit = TRUE)
  
  observeEvent(input$run, {
    tryCatch(scroll_site(input$url),
             error = function(e){
               sendSweetAlert(session = session, 
                              title = "Python Failed!", 
                              text = "Bro something is broken",
                              type = "error",
                              btn_labels = c("Cool..."),
                              closeOnClickOutside = TRUE)
             })
  },
  ignoreInit = TRUE)

}

shinyApp(ui, server)