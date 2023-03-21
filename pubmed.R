library(easyPubMed)
#
my_query <- 'Willian Zambuzzi[AU]'
my_entrez_id <- get_pubmed_ids(my_query)
my_abstracts_txt <- fetch_pubmed_data(my_entrez_id)

my_titles <- custom_grep(my_abstracts_txt, "ArticleTitle", "char")

my_abstracts <- custom_grep(my_abstracts_txt,"AbstractText", "char")

#
library(wordcloud)
library(tm)
text <- my_abstracts
# Create a corpus
docs <- Corpus(VectorSource(text))

docs <- docs %>%
  tm_map(removeNumbers) %>%
  tm_map(removePunctuation) %>%
  tm_map(stripWhitespace)
docs <- tm_map(docs, content_transformer(tolower))
docs <- tm_map(docs, removeWords, stopwords("english"))

dtm <- TermDocumentMatrix(docs)
matrix <- as.matrix(dtm)
words <- sort(rowSums(matrix),decreasing=TRUE)
df <- data.frame(word = names(words),freq=words)


set.seed(42) # for reproducibility
wordcloud(words = df$word,
          freq = df$freq, min.freq = 1,
          max.words=200, random.order=FALSE,
          rot.per=0.35,
          colors=brewer.pal(8, "Dark2"),scale=c(3.5,0.25))
wordcloud2::wordcloud2(data=df, size=1.6, color='random-dark')
