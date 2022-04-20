install.packages("rvest")
install.packages("xml")
library(robotstxt)
library(rvest)
library(xml2)
library(stringr)
library(dplyr)
library(ggplot2)
library(plotly)
library(curl)

paths_allowed("https://www.airbnb.co.in/s/india/homes?tab_id=home_tab&
refinement_paths%5B%5D=%2Fhomes&flexible_trip_dates%5B%5D=april&
flexible_trip_dates%5B%5D=may&flexible_trip_lengths%5B%5D=weekend_trip&
date_picker_type=calendar&source=structured_search_input_header&
search_type=filter_change&query=India&checkin=2022-04-09&checkout=2022-04-16&
adults=1")

B_Url <- "https://www.airbnb.co.in/s/Bangalore--Karnataka/homes?tab_id=home_tab&refinement_paths%5B%5D=%2Fhomes&flexible_trip_dates%5B%5D=april&flexible_trip_dates%5B%5D=may&flexible_trip_lengths%5B%5D=weekend_trip&date_picker_type=calendar&query=Bangalore%2C%20Karnataka&source=structured_search_input_header&search_type=autocomplete_click&place_id=ChIJbU60yXAWrjsR4E9-UejD3_g&federated_search_session_id=d8b565f7-4fb0-4f58-8664-555ff419554b&pagination_search=true&items_offset="
Last_Url <- "&section_offset=3"

Bangalore_Data <- vector()
b1 <- "https://www.airbnb.co.in/rooms/594813048526680982?federated_search_id=cd843a0a-2e7f-4c78-8853-e5eaaa657fdb&source_impression_id=p3_1649582655_qt3p5oMwDYuECEx0"
print(b1)
Bangalore_Data <- c(Bangalore_Data,read_html(b1) %>%
                      html_nodes(css="_fecoyn4") %>% 
                      html_text())

for(i in seq(from=0, to = 280, by =20))
{
B_Url <- paste0(B_Url,i,Last_Url)
print(B_Url)
Bangalore_Data <- c(Bangalore_Data,read_html(B_Url) %>%
                      html_nodes(css="._1e9w8hic") %>% 
                      html_text())
print(i)
} 


