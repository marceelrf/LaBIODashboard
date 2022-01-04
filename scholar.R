library(scholar)

#Get scholar code
WFZ <- scholar::get_scholar_id(last_name = "Zambuzzi",first_name = "Willian")

#Number of articles
scholar::get_num_articles(WFZ)

#Publications
tidy_pubs <-scholar::get_publications(WFZ)

