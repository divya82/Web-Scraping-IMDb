install.packages("rvest")
install.packages("ggplot2")
library(robotstxt)
library(rvest)
library(stringr)
library(tidyverse)
library(dplyr)
library(stringr)
library(ggplot2)
library(xml2)

paths_allowed("https://www.imdb.com/search/title/?title_type=feature,tv_movie,tv_series,documentary&num_votes=1000")

Movie_Data <- tibble()

for(page in seq(from=1, to = 1000, by=50)) {
  
  web <- paste("https://www.imdb.com/search/title/?release_date=2018-01-01,2018-12-31&start=",toString(page),"&ref_=adv_nxt",sep="")   
  website <- read_html(web)
  
  Rank_Data <- html_nodes(website,'.text-primary')
  Movie_Rank_Data <- html_text(Rank_Data)
  print(Movie_Rank_Data)
  
  title_Data <- html_nodes(website,".lister-item-header a")
  Movie_title_Data <- html_text(title_Data)
  print(Movie_title_Data)
  
  year_Data <- html_nodes(website,".lister-item-year")
  Movie_year_Data <- html_text(year_Data)
  print(Movie_year_Data)
  
  genre_Data <- html_nodes(website,".genre")
  Movie_genre_Data <- html_text(genre_Data)
  Movie_genre_Data <- gsub("\n","",Movie_genre_Data)
  Movie_genre_Data <- gsub(" ","",Movie_genre_Data)
  Movie_genre_Data <- gsub(",.*","",Movie_genre_Data)
  Movie_genre_Data <- as.factor(Movie_genre_Data)
  print(Movie_genre_Data)
  
  rating_Data <- html_nodes(website,".ratings-imdb-rating strong")
  Movie_rating_Data <- html_text(rating_Data)
  print(Movie_rating_Data)
  
  gross_votes_Data <- html_nodes(website,".sort-num_votes-visible")
  Movie_gross_votes_Data <- html_text(gross_votes_Data)
  print(Movie_gross_votes_Data)
  
  Data <- tibble(Rank = Movie_Rank_Data, Title= Movie_title_Data,Genre= Movie_genre_Data, Rating= Movie_rating_Data,Year_ = Movie_year_Data, Gross_Votes = Movie_gross_votes_Data)
  Movie_Data <- bind_rows(Movie_Data,Data)

  print(page)
}

View(Movie_Data)

Year <- regmatches(Movie_Data$Year_,regexpr("2018",Movie_Data$Year_))
Year <- as.numeric(Year)
Movie_Data <- cbind(Year,Movie_Data)
Movie_Data$Year_=NULL

Movie_Data <- separate(data= Movie_Data, col = Gross_Votes ,into = c("R1","R2","Votes","R3","Gross"),sep= "\n")
Movie_Data$R1 = NULL
Movie_Data$R2 = NULL
Movie_Data$R3 = NULL

Movie_Data$Votes <- trimws(Movie_Data$Votes,whitespace = "[ \t\r]")
Movie_Data$Votes <- gsub(",","",Movie_Data$Votes)
Movie_Data$Votes <- as.numeric(Movie_Data$Votes)

Movie_Data$Gross <- trimws(Movie_Data$Gross,whitespace = "[ \t\r]")
Movie_Data$Gross <- substr(Movie_Data$Gross,2,regexpr("M",Movie_Data$Gross))
Movie_Data$Gross <- gsub("M","",Movie_Data$Gross)
Movie_Data$Gross <- gsub("$ ","",Movie_Data$Gross)
Movie_Data$Gross <- as.numeric(Movie_Data$Gross)
Movie_Data$Gross <- Movie_Data$Gross*1000000

Movie_Data_G <- Movie_Data %>% select(Genre, Votes,Rating) %>% group_by(Genre) %>% summarise(Total_Votes = sum(Votes),Avg_Rating = mean(Rating))

ggplot(data = Movie_Data_G)+ geom_bar(mapping = aes(x = Genre,y =Avg_Rating),stat='identity',fill="#30D5C8")+
  geom_line(aes(x = Genre,y =Avg_Rating, group=1),color="red",size=1.5)+
  theme(axis.text.x = element_text(angle= 45),axis.text.y = element_text(angle= 45))+
  labs(title = "Average Rating for Different Genre")

ggplot(data = Movie_Data_G)+ geom_bar(aes(x="",y =Total_Votes,fill=Genre),stat='identity')+
  coord_polar("y", start=0)  +scale_fill_brewer(palette="Dark2")+
labs(title = "Movie Genre having maximum votes share", subtitle = "Top 3 Genre are ACTION,COMEDY,DRAMA")

View(Movie_Data)

write.csv(Movie_Data,"Movies_Data.csv")