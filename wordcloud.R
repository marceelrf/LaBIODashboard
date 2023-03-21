library(rentrez)
library(XML)
library(tokenizers)
library(stopwords)
library(wordcloud2)

pmids <- list()

query <- paste(paste0(tidy_pubs$title,"[TITL]"),collapse = " OR ")

for (i in nrow(tidy_pubs)) {
  pmids[[i]] <- entrez_search(db = "pubmed",
                              term = paste0(tidy_pubs$title[i],"[TITL]"))
}

pmids <- entrez_search(db = "pubmed",
              term = query,use_history = T)

pmids

fetch_pubmed <- entrez_fetch(db = "pubmed",
                             id = pmids$ids,
                             rettype = "xml",
                             parsed = TRUE)

abstracts <- xpathApply(fetch_pubmed,
                        '//PubmedArticle//Article',
                        function(x) xmlValue(xmlChildren(x)$Abstract))

Text <- abstracts %>% unlist() %>% paste(collapse = ".")

freq_tokens <- Text %>%
  tokenize_words() %>%
  tibble() %>%
  unnest(.) %>%
  rename("tokens" = ".") %>%
  filter(!(tokens %in% stopwords(source ="stopwords-iso"))) %>%
  count(tokens) %>%
  arrange(desc(n)) %>%
  #manual filter
  filter(!(tokens %in% c("1","â","nha","wiley","2019")))

set.seed(42)
wc <- wordcloud(words = freq_tokens$tokens,
          freq = freq_tokens$n,
          colors = brewer.pal(n = 10,name = "Accent"),
          min.freq = 5,
          rot.per = .35,
          max.words = 100,
          size=.6,scale = c(.1,1))
wordcloud2(freq_tokens,size = 2, minRotation = -pi/2, maxRotation = -pi/2,
           fontFamily = )
