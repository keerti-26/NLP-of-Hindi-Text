
## install.packages("tibble")
## install.packages("ggplot2")
## install.packages("dplyr")

# Bring in the namespaces in a NEW RStudio session in this order..
library(tibble)
library(dplyr)
library(ggplot2)

## udpipe is available on CRAN and you may install it now
## &reply 'y' to 'Do you want to install from sources the package which needs compilation?'
install.packages('udpipe')

## Input Dataset includes the entire corpus of articles published by the ABC 
## website in the given time range. With a volume of 200 articles per day 
## and a good focus on international news. Unpack abcnews-date-text.csv and
## put the file in RStudio's current work directory (getwd()/setwd())
getwd()
# Session | Set Working Directory | Choose directory..


## ============================================================================
## Section 1: Data cleaning and exploration
## ============================================================================

## let's read in the data
hindi <- readLines (con <- file("hindi.txt", encoding = "UTF-16"))
hindi


## ============================================================================
## Section 2: Staging with pretrained language model
## ============================================================================

## Let's download the english data model
library(udpipe)

## At first time model download execute the below line

model <- udpipe_download_model(language = "hindi")
## And then
model <- udpipe_load_model(file = 'hindi-hdtb-ud-2.4-190531.udpipe')
x <- udpipe_annotate(model,hindi)
x <- data.frame(x)
## In order to check all tokens
x$token
##In order to check all parts oof speech
x$upos

## ============================================================================
## Section 3: Analysis
## ============================================================================

## To plot Part-of-speech tags from the given text, use package lattice
library(lattice)
stats <- txt_freq(x$upos)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = stats, col = "yellow", 
         main = "UPOS (Universal Parts of Speech)\n frequency of occurrence", 
         xlab = "Freq")


## most common nouns
stats <- subset(x, upos %in% c("NOUN")) 
stats <- txt_freq(stats$token)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = head(stats, 20), col = "cadetblue", 
         main = "Most occurring nouns", xlab = "Freq")


## the most occurring adjectives
## ADJECTIVES
stats <- subset(x, upos %in% c("ADJ")) 
stats <- txt_freq(stats$token)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = head(stats, 20), col = "purple", 
         main = "Most occurring adjectives", xlab = "Freq")


## VERBS
stats <- subset(x, upos %in% c("VERB")) 
stats <- txt_freq(stats$token)
stats$key <- factor(stats$key, levels = rev(stats$key))
barchart(key ~ freq, data = head(stats, 20), col = "gold", 
         main = "Most occurring Verbs", xlab = "Freq")


## Let's goup nouns and adjectives for a better understanding of the roles of 
## nouns & Adjectives
stats <- keywords_rake(x = x, term = "lemma", group = "doc_id", 
                       relevant = x$upos %in% c("NOUN", "ADJ"))
stats$key <- factor(stats$keyword, levels = rev(stats$keyword))
barchart(key ~ rake, data = head(subset(stats, freq > 3), 20), col = "red", 
         main = "Keywords identified by RAKE", 
         xlab = "Rake")

## Using a sequence of POS tags (noun phrases / verb phrases)
x$phrase_tag <- as_phrasemachine(x$upos, type = "upos")
stats <- keywords_phrases(x = x$phrase_tag, term = tolower(x$token), 
                          pattern = "(A|N)*N(P+D*(A|N)*N)*", 
                          is_regex = TRUE, detailed = FALSE)
stats <- subset(stats, ngram > 1 & freq > 3)
stats$key <- factor(stats$keyword, levels = rev(stats$keyword))
barchart(key ~ freq, data = head(stats, 20), col = "magenta", 
         main = "Keywords - simple noun phrases", xlab = "Frequency")

## Let's plot a word cloud
library(wordcloud)
wordcloud(words = stats$key, freq = stats$freq, min.freq = 3, max.words = 100,
          random.order = FALSE, colors = brewer.pal(6, "Dark2"))
