#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(plotly)
library(tidyr)
library(dplyr)
library(flexdashboard)


df <- read.csv(file = "the_office.csv", check.names = FALSE)[,2:12]

shinyServer(function(input, output) {
    
    output$plot_1 <- renderPlotly({
        ggplotly(
            tooltip = c("text", "count"),
            ggplot(
                df %>%
                    filter(Season %in% input$seasons) %>%
                    filter(Ratings >= input$min_rating),
                aes(x = Season,
                    fill = Season,
                    text = paste("Season: ", Season))
            ) +
                geom_bar() +
                theme_classic() +
                theme(legend.position = "none") +
                scale_x_continuous(breaks = 1:9) +
                labs(
                    y = "Episodes"
                )
        )
    })
    
    output$plot_2 <- renderPlotly({
        ggplotly(
            tooltip = "text",
            ggplot(
                df %>%
                    filter(Season %in% input$seasons),
                aes(x = Season,
                    y = Ratings,
                    color = Season,
                    text = paste("Title: ", EpisodeTitle, "\nRatings: ", Ratings))
            ) +
                geom_point() +
                theme_classic() +
                theme(legend.position = "none") +
                scale_x_continuous(breaks = 1:9)
        )
    })
    
    output$plot_3 <- renderPlotly({
        ggplotly(
            tooltip = "",
            ggplot(
                df %>%
                    mutate(person = ifelse(grepl(tolower(input$character_name), tolower(About)), 1, 0)) %>%
                    filter(Season %in% input$seasons) %>%
                    group_by(Season) %>%
                    summarise(sum = sum(person)) %>%
                    filter(sum > 0),
                aes(
                    x = Season,
                    y = sum
                )
            ) +
                geom_smooth(se = FALSE,
                            color = "#336a98") +
                labs(y = "Character importance") +
                theme_classic() +
                theme(legend.position = "none") +
                xlim(c(min(df$sum), max(df$sum))) +
                scale_x_continuous(breaks = 1:9)
        )
    })
    
    output$plot_4 <- renderPlotly({
        ggplotly(
            height = 600,
            tooltip = "text",
            ggplot(df %>%
                       filter(Season %in% input$seasons) %>%
                       select(Writers, Ratings) %>%
                       mutate(Writers = strsplit(as.character(Writers), " | ", fixed = TRUE)) %>%
                       unnest(Writers) %>%
                       mutate(Writers = strsplit(as.character(Writers), " and ", fixed = TRUE)) %>%
                       unnest(Writers) %>%
                       group_by(Writers) %>%
                       summarise(avg = mean(Ratings)) %>%
                       arrange(desc(avg)) %>%
                       head(input$best_writers),
                   aes(
                       x = avg,
                       y = reorder(Writers, avg),
                       text = paste("Writer: ", Writers,"\nMean rating: ", round(avg, 2))
                   )
            ) +
                geom_point(col = "#336a98",
                           size = 3) +
                geom_segment(
                    aes(x = min(avg),
                        xend = max(avg),
                        y = Writers,
                        yend = Writers
                    ),
                    linetype = "dashed",
                    size = 0.1
                ) +
                labs(x = "Mean rating",
                     y = "") +
                theme_classic() +
                scale_x_continuous(breaks = seq(0, 10, 0.25))
        )
    })
    
    output$gauge_1 <- renderGauge({
        gauge(nrow(df %>% 
                       filter(Season %in% input$seasons) %>%
                       filter(Ratings >= input$min_rating)),
              min = 0,
              max = nrow(df),
              sectors = gaugeSectors(success = c(0, nrow(df) / 2),
                                     warning = c(nrow(df) / 2, nrow(df) - (nrow(df) / 4)),
                                     danger = c(nrow(df) - (nrow(df) / 4), nrow(df)),
                                     colors = c("#132b43", "#336a98", "#56b1f7")
              )
        )
    })
    
    output$gauge_2 <- renderGauge({
        gauge(sum(df %>%
                  mutate(person = ifelse(grepl(tolower(input$character_name), tolower(About)), 1, 0)) %>%
                  filter(Season %in% input$seasons) %>%
                  group_by(Season) %>%
                  summarise(sum = sum(person)) %>%
                  filter(sum > 0) %>%
                  select(sum)),
              min = 0,
              max = nrow(df),
              sectors = gaugeSectors(success = c(0, nrow(df) / 4),
                                     warning = c(nrow(df) / 4, nrow(df) / 2),
                                     danger = c(nrow(df) / 2, nrow(df)),
                                     colors = c("#132b43", "#336a98", "#56b1f7")
              )
        )
    })
    
    
    
    output$dataTable_1 <- renderDataTable({if(!is.null(event_data("plotly_relayout")$`xaxis.range[0]`)) filter(df %>% select("Season", "EpisodeTitle", "About", "Ratings"),
                                                                                                      Season >= event_data("plotly_relayout")$`xaxis.range[0]` &
                                                                                                      Season <= event_data("plotly_relayout")$`xaxis.range[1]` &
                                                                                                      Ratings >= event_data("plotly_relayout")$`yaxis.range[0]` &
                                                                                                      Ratings <= event_data("plotly_relayout")$`yaxis.range[1]`)},
                                     options = list(pageLength = 10, info = FALSE, autoWidth = FALSE))
    
    output$text_1 <- renderText(paste("Episodes with ratings greater than", input$min_rating))
    output$text_2 <- renderText(paste("Number of episodes with ratings greater than", input$min_rating))
    output$text_3 <- renderText(paste(input$character_name, "'s importance over all the time"))
    output$text_4 <- renderText(paste(input$character_name, "'s importance over the time"))
    output$text_5 <- renderText(paste(input$best_writers, " best writers of The Office episodes"))
})