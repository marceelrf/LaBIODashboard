library(scholar)
library(extrafont)
library(glue)
library(plotly)
library(tidyverse)

#Get scholar code
MRF <- scholar::get_scholar_id(last_name = "Ferreira",first_name = "Marcel",affiliation = "UNESP")

#Number of articles
scholar::get_num_articles(MRF)

#Publications
tidy_pubs <- scholar::get_publications(MRF)

#Cites per year plot
(
  p_cites_per_year <- scholar::get_citation_history(MRF) %>%
  ggplot(aes(x = year, y = cites)) +
  geom_line(col = "#800000") +
  geom_point(size = 3,col = "#800000") +
  geom_text(aes(label = cites),nudge_y = 5,
            color = "#800000",family = "Segoe UI",size = 6) +
  scale_x_continuous(breaks = c(2016:year(Sys.Date()))) +
  labs(x = "",
       y = "",
       title = "Cites per year",
       caption = paste("Accessed at",Sys.Date())) +
  theme(text = element_text(family = "Segoe UI",size = 15),
        plot.title = element_text(size = 30),
        panel.background = element_rect(fill = "white"),
        panel.grid.major.y = element_line(colour = "gray90",linewidth = .5,
                                          linetype = "solid"),
        panel.grid.major.x = element_blank())
  )

library(plotly)

df1 <-scholar::get_citation_history(MRF)
# assuming the data is stored in a data frame called `df`
fig <- plot_ly(df1, x = ~year, y = ~cites, type = "scatter", mode = "lines+markers",
               line = list(color = "#800000"), marker = list(color = "#800000")) %>%
  layout(title = "Cites per year",
         xaxis = list(title = "", tickvals = seq(2016, year(Sys.Date()), 1)),
         yaxis = list(title = ""),
         annotations = list(text = paste("Accessed at", Sys.Date()), xref = "paper", yref = "paper",
                            x = 0.95, y = 1.05, showarrow = FALSE)) %>%
  add_text(x = ~year, y = ~cites, text = ~cites, textposition = "top center",
           textfont = list(size = 10, family = "Segoe UI"),
           showlegend = FALSE, color = "#800000")
fig

# Abstracts ---------------------------------------------------------------

tidy_pubs %>%
  select(title,cites,year,pubid) %>%
  mutate(cites_py = cites/(1+2023-year)) %>%
  arrange(desc(cites_py)) %>%
  slice_head(n = 5) %>%
  select(title,pubid)


get_publication_abstract(id = MRF,pub_id = tidy_pubs$pubid[1])
get_publication_url(id = MRF,pub_id = tidy_pubs$pubid[1])


# h-index -----------------------------------------------------------------
tidy_pubs %>%
  select(cites) %>%
  rownames_to_column(var = "index") %>%
  mutate(index = as.numeric(index),
         Cond = case_when(
    cites >= (index) ~ "Sim",
    TRUE ~ "No"
  )) %>%
  filter(Cond == "Sim") %>%
  summarise(h = max(index))

scholar::predict_h_index(id = MRF)
