library(scholar)
#library(extrafont)
#library(glue)
#library(plotly)
library(tidyverse)
library(rentrez)
library(XML)
library(tokenizers)
library(stopwords)
#library(wordcloud2)


dash_list <- list()
#Marcel Ferreira - Scholar ID
MRF <- "lS42GYwAAAAJ"
# #Number of articles
# scholar::get_num_articles(MRF)

#Publications
tidy_pubs <- scholar::get_publications(MRF)

#Cites per year plot
# (
#   p_cites_per_year <- scholar::get_citation_history(MRF) %>%
#   ggplot(aes(x = year, y = cites)) +
#   geom_line(col = "#800000") +
#   geom_point(size = 3,col = "#800000") +
#   geom_text(aes(label = cites),nudge_y = 5,
#             color = "#800000",family = "Segoe UI",size = 6) +
#   scale_x_continuous(breaks = c(2016:year(Sys.Date()))) +
#   labs(x = "",
#        y = "",
#        title = "Cites per year",
#        caption = paste("Accessed at",Sys.Date())) +
#   theme(text = element_text(family = "Segoe UI",size = 15),
#         plot.title = element_text(size = 30),
#         panel.background = element_rect(fill = "white"),
#         panel.grid.major.y = element_line(colour = "gray90",linewidth = .5,
#                                           linetype = "solid"),
#         panel.grid.major.x = element_blank())
#   )

# library(plotly)
#
# df1 <-scholar::get_citation_history(MRF)
# # assuming the data is stored in a data frame called `df`
# fig <- plot_ly(df1, x = ~year, y = ~cites, type = "scatter", mode = "lines+markers",
#                line = list(color = "#800000"), marker = list(color = "#800000")) %>%
#   layout(title = "Cites per year",
#          xaxis = list(title = "", tickvals = seq(2016, year(Sys.Date()), 1)),
#          yaxis = list(title = ""),
#          annotations = list(text = paste("Accessed at", Sys.Date()), xref = "paper", yref = "paper",
#                             x = 0.95, y = 1.05, showarrow = FALSE)) %>%
#   add_text(x = ~year, y = ~cites, text = ~cites, textposition = "top center",
#            textfont = list(size = 10, family = "Segoe UI"),
#            showlegend = FALSE, color = "#800000")
# fig

# Abstracts ---------------------------------------------------------------

# tidy_pubs %>%
#   select(title,cites,year,pubid) %>%
#   mutate(cites_py = cites/(1+2023-year)) %>%
#   arrange(desc(cites_py)) %>%
#   slice_head(n = 5) %>%
#   select(title,pubid) %>%
#   group_by(title,pubid) %>%
#   mutate(url = get_publication_url(id = MRF,pub_id = pubid)) %>%
#   select(-pubid)


# get_publication_abstract(id = MRF,pub_id = tidy_pubs$pubid[1])
# get_publication_url(id = MRF,pub_id = tidy_pubs$pubid[1])


# h-index -----------------------------------------------------------------
# hMRF <- tidy_pubs %>%
#   select(cites) %>%
#   rownames_to_column(var = "index") %>%
#   mutate(index = as.numeric(index),
#          Cond = case_when(
#     cites >= (index) ~ "Sim",
#     TRUE ~ "No"
#   )) %>%
#   filter(Cond == "Sim") %>%
#   summarise(h = max(index)) %>%
#   pull(h)



# pubmed ------------------------------------------------------------------

pmids <- list()

# ERROR - 414
# query <- paste(paste0(tidy_pubs$title,"[TITL]"),collapse = " OR ")
#
# pmids <- entrez_search(db = "pubmed",
#                        term = query,
#                        use_history = TRUE)
#
#
# fetch_pubmed <- entrez_fetch(db = "pubmed",
#                              id = pmids$ids,
#                              rettype = "xml",
#                              parsed = TRUE)
#
# abstracts <- xpathApply(fetch_pubmed,
#                         '//PubmedArticle//Article',
#                         function(x) xmlValue(xmlChildren(x)$Abstract))
#
# Text <- abstracts %>% unlist() %>% paste(collapse = ".")

vec_rule <- c(seq(1,length(tidy_pubs$title), by = 20))
for(i in vec_rule) {
  final <- i + (20-1)
  Text <- NULL

  query <- (discard(tidy_pubs$title[i:final],is.na))
  query <- paste(paste0(query,"[TITL]"),collapse = " OR ")

  pmids <- entrez_search(db = "pubmed",
                         term = query,
                         use_history = TRUE)

  fetch_pubmed <- entrez_fetch(db = "pubmed",
                               id = pmids$ids,
                               rettype = "xml",
                               parsed = TRUE)

  abstracts <- xpathApply(fetch_pubmed,
                          '//PubmedArticle//Article',
                          function(x) xmlValue(xmlChildren(x)$Abstract))

  Text <- append(Text,abstracts %>% unlist() %>% paste(collapse = "."))
  Sys.sleep(1)
}

freq_tokens <- Text %>%
  tokenize_words() %>%
  tibble() %>%
  unnest(.) %>%
  rename("tokens" = ".") %>%
  filter(!(tokens %in% stopwords(source ="stopwords-iso"))) %>%
  count(tokens) %>%
  arrange(desc(n)) %>%
  #manual filter
  filter(!(tokens %in% c("1","â","nha","wiley","2019","elsevier","2020")))

# save list to dash -------------------------------------------------------


dash_list$nPub <- nrow(tidy_pubs)
dash_list$nCites <- sum(tidy_pubs$cites)
#get h index
dash_list$hIndex <- tidy_pubs %>%
  select(cites) %>%
  rownames_to_column(var = "index") %>%
  mutate(index = as.numeric(index),
         Cond = case_when(
           cites >= (index) ~ "Sim",
           TRUE ~ "No"
         )) %>%
  filter(Cond == "Sim") %>%
  summarise(h = max(index)) %>%
  pull(h)
#sugestion of  most relevant papers
dash_list$tableSug <- tidy_pubs %>%
  select(title,cites,year,pubid) %>%
  mutate(cites_py = cites/(1+year(Sys.Date())-year)) %>%
  arrange(desc(cites_py)) %>%
  #slice_head(n = 5) %>%
  select(title,year,pubid) %>%
  dplyr::group_by(title,pubid) %>%
  mutate(url = get_publication_url(id = MRF,pub_id = pubid)) %>%
  #ungroup() %>% <-------- Add isso para testar

  select(-pubid)

dash_list$tidycites <- scholar::get_citation_history(MRF)
dash_list$freq_tokens <- freq_tokens
readr::write_rds(x = dash_list,file = "data/dash_list.rds")
