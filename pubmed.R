install.packages("RISmed")
library(RISmed)


pmid <- EUtilsQuery("zambuzzi[au]")
pmid <- EUtilsSummary(query = pmid)
res1 <- EUtilsSummary("pinkeye", type="esearch", db="pubmed", datetype='pdat', mindate=2000, maxdate=2015, retmax=500)




# NOT WORKING -------------------------------------------------------------


# library(easyPubMed)
#
my_query <- 'Willian Zambuzzi[AU]'
my_entrez_id <- get_pubmed_ids(my_query)
my_abstracts_txt <- fetch_pubmed_data(my_entrez_id, format = "abstract")
