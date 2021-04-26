#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(flexdashboard)


# Define UI for application that draws a histogram
shinyUI(fluidPage(
    theme = shinytheme("flatly"),

    tags$head(
        tags$style(HTML(
            "
            tfoot {
                display: none;
            }
            
            h1  {
                text-align: center;
                font-size: 70px;
                margin: 60px auto;
            }
            
            img {
                max-width: 100%;
            }
            
            .control-label, h4 {
                font-size: 18px;
                font-weight: bold;
                line-height: 1.15;
                margin-top: 10px;
            }
            
            h5 {
                font-size: 18px;
                margin-top: 30px;
                margin-left: 30px;
            }
            
            #github {
                margin-left: 100px;
            }
            
            
            .plotly {
                margin-top: 50px;
            }
            
            li.active a {
                font-weight: bold;
                background-color: #ecf0f1 !important;
            }
            
            #gauge_1, #gauge_2 {
                max-height: 150px !important;
            }
            
            #text_1, #text_3 {
                margin-top: 70px;
                margin-bottom: 30px;
            }
            
            #text_2, #text_4, #text_5 {
                margin-left: 30px;
                margin-top: 30px;
            }
            
            #best_writers {
                margin-bottom: 50px;
            }
            
            #seasons, .select_menu {
                padding: 20px;
                background-color: #ecf0f1;
                border-radius: 15px;
                margin: 30px auto;
            }
            
            .shiny-input-container {
                margin: 0 auto;
                margin-top: 20px;
            }
            "
            )
        )
    ),

    fluidRow(
        column(2,
            img(src='./logo.png', align = "center"),
            checkboxGroupInput(
                "seasons",
                "Select seasons to consider",
                choices = 1:9,
                selected = 1:9
            )
        ),
        column(10,
            headerPanel("The Office episodes"),
            tabsetPanel(
                tabPanel("Choose episodes",
                         h5("Do you struggle to choose an episode of the best series? Select area on the figure below to refine search and list episodes"),
                         plotlyOutput("plot_2"),  
                         dataTableOutput("dataTable_1")
                ),
                tabPanel("Seasons summary",
                    fluidPage(
                        fluidRow(
                            column(12,
                                   h5("It's well known that sometimes one episode it is not enough for an evening. In such a case you can choose whole season with the highest number of episodes with rating above some threshold.")),
                            column(3,
                                class = "select_menu",
                                h4("Select minimum rating of episodes"),
                                sliderInput(
                                    "min_rating",
                                    "",
                                    min = 0,
                                    max = 10,
                                    value = 5,
                                    step = 0.1
                                ),
                                h4(textOutput("text_1")),
                                gaugeOutput("gauge_1")
                            ),
                            column(9,
                                h3(textOutput("text_2")),
                                plotlyOutput("plot_1")
                            )
                        )
                    )
                ),
                tabPanel("Characters importance",
                     fluidPage(
                         fluidRow(
                             column(12,
                                    h5("Did you ever wonder how important is given character for The Office? Let's check it! Importance of the character is computed using number of occurences of the character's name in the episode description.")),
                             column(3,
                                class = "select_menu",
                                h4("Character name"),
                                textInput(inputId = "character_name", label = "", value = "Michael"),
                                h4(textOutput("text_3")),
                                gaugeOutput("gauge_2")
                             ),
                             column(9,
                                h3(textOutput("text_4")),
                                plotlyOutput("plot_3")
                            )
                        )
                    )
                ),
                tabPanel("Best writers",
                    fluidPage(
                        fluidRow(
                            column(12,
                                   h5("Did you ever wonder who had written best episodes of The Office? Below you can see the ranking of best writers.")
                                   ),
                            column(3,
                                class = "select_menu",
                                h4("Select number of writers to display"),
                                numericInput(inputId = "best_writers", label = "", value = 20, min = 0, max = 41)
                                
                            ),
                            column(9,
                                   h3(textOutput("text_5")),
                                   plotlyOutput("plot_4")
                            )
                        )
                    )         
                ),
                tabPanel("About",
                    fluidPage(
                        fluidRow(
                            column(12,
                                h5("This project has been created as an assignment for Data visualisation course, under the supervision of Ph. D. Dariusz Brzeziński. The course run at Poznań University of Technology. Source code of this project is publicly available on my github:"),
                                a(id="github", href = "https://github.com/jkarolczak/the-office-episodes", "https://github.com/jkarolczak/the-office-episodes"),
                                h5("I hope you to have fun using this dashboard. If not, if you want to see any improvement or new feature, create an issue on github. I'm also opened to pull requests.  Feel free to reuse this code for your own purpose.")
                            )
                        )
                    )
                )
            
            )
        )
    )
))
