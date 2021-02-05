### NAME:         Data Science Final Project
### UNIVERSITY:   Lewis University
### CLASS:        DATA 59000 - Data Science Project
### AUTHOR:       Katherine Palermo
### LAST UPDATED: November 29, 2019


# import packages

from bs4 import BeautifulSoup
import requests
import random
import nltk
from nltk.tokenize import word_tokenize
from nltk.util import ngrams
from nltk.corpus import stopwords
nltk.download('stopwords')
from nltk.stem import WordNetLemmatizer
import datetime
from collections import Counter
import string

# define stop words
stop_words = stopwords.words('english')


## DEFINE FUNCTIONS

def create_billboard_url(genre, year):
    urls = []
    if genre == 'pop': # Pop songs do not have the word "hot" in the URL
        urls.append('https://www.billboard.com/charts/year-end/' + str(year) + '/' + genre + '-songs')
    else:
        urls.append('https://www.billboard.com/charts/year-end/' + str(year) + '/hot-' + genre + '-songs')
    return urls

def scrape_page_content(url):
    response = requests.get(url)  # puts all of the information from the URL in the response variable
    page_content = BeautifulSoup(response.text, 'html.parser')
    return page_content

def get_artist_names(page_content):
    artists = page_content.select(".ye-chart-item__artist")
    artists = [artist.text for artist in artists]
    artists = [artist.strip('\n') for artist in artists]
    artists = [artist.replace(" ", "-") for artist in artists]
    artists = [artist.replace("&", "and") for artist in artists]
    artists = [artist.replace("/", "and") for artist in artists]
    artists = [artist.replace("-x-", "-and-") for artist in artists]
    artists = [artist.replace(".", "") for artist in artists]
    artists = [artist.capitalize() for artist in artists]
    sep_feat = '-featuring'
    artists = [artist.split(sep_feat, 1)[0] for artist in artists]
    sep_plus = '-+'
    artists = [artist.split(sep_plus, 1)[0] for artist in artists]
    sep_costar = '-co-star'
    artists = [artist.split(sep_costar, 1)[0] for artist in artists]
    sep_comma = ',-'
    artists = [artist.split(sep_comma, 1)[0] for artist in artists]
    artists = [artist.lstrip('-') for artist in artists]
    return artists

def get_song_titles(page_content):
    titles = page_content.select(".ye-chart-item__title")
    titles = [title.text for title in titles]
    titles = [title.strip('\n') for title in titles]
    titles = [title.lstrip() for title in titles]
    titles = [title.replace(" ", "-") for title in titles]
    titles = [title.replace("&", "and") for title in titles]
    titles = [title.replace("'", "") for title in titles]
    titles = [title.replace("'", "") for title in titles]
    titles = [title.replace("(", "") for title in titles]
    titles = [title.replace(")", "") for title in titles]
    titles = [title.replace(".", "") for title in titles]
    titles = [title.replace(",", "") for title in titles]
    titles = [title.replace("#", "") for title in titles]
    titles = [title.replace("-:-", "") for title in titles]
    titles = [title.replace("\n-", "") for title in titles]
    titles = [title.replace("?", "") for title in titles]
    titles = [title.lower() for title in titles]
    return titles

def create_genius_urls(artists,titles):
    i = 0
    genius_urls = []
    for song in artists:
        genius_url = 'https://genius.com/' + artists[i] + '-' + titles[i] + '-lyrics'
        genius_urls.append(genius_url)
        i += 1
    return genius_urls

def scrape_lyrics(genius_urls_genre):
    genre_lyrics = []
    for url in genius_urls_genre:
        response = requests.get(url)
        page_content = BeautifulSoup(response.text, 'html.parser')
        # use a try/except to catch any bad URLs or URLs that don't have lyrics associated with the page
        try:
            lyrics = page_content.find_all("p")[0].text.lower()
            lyrics_no_punc = lyrics.translate(str.maketrans('','',string.punctuation))  # remove punctuation
            lyrics_tokenized = word_tokenize(lyrics_no_punc)
            lyrics_tokenized = [word for word in lyrics_tokenized if word not in stop_words]  # remove stop words
            genre_lyrics.append(lyrics_tokenized)
        except:
            print('URL without lyrics: ' + url)
    return genre_lyrics

def label_lyrics(lyrics,genre):
    lyrics_labeled = [(song, genre) for song in lyrics]
    return lyrics_labeled

def get_data(genres, year):

    # create Billboard URLs for each of the genres
    billboard_urls = [create_billboard_url(genre, year) for genre in genres]

    # scrape the Billboard URLs to get their page contents
    page_contents = [scrape_page_content(url[0]) for url in billboard_urls]

    # get the names of the artists from the web page contents
    artists_by_genre = [get_artist_names(content) for content in page_contents]

    # get the names of the song titles from the web page contents
    titles_by_genre = [get_song_titles(content) for content in page_contents]

    # create Genius URLs for every song in each of the genres using the previously scraped Billboard data
    genius_urls_by_genre = []
    i = 0
    for genre in artists_by_genre:
        genius_urls_by_genre.append(create_genius_urls(artists_by_genre[i], titles_by_genre[i]))
        i += 1

    # scrape the Genius URLs to get their lyrical contents
    lyrics_by_genre = []
    i = 0
    for urls in genius_urls_by_genre:
        lyrics_by_genre.append(scrape_lyrics(genius_urls_by_genre[i]))
        i += 1

    # label the lyrics with the genre to which they belong
    labeled_lyrics_list = []
    i = 0
    for genre in lyrics_by_genre:
        labeled_lyrics_list.append(label_lyrics(lyrics_by_genre[i], genres[i]))
        i += 1

    # remove songs from their genre lists and place into single list to allow for shuffling
    labeled_lyrics = []
    for genre in labeled_lyrics_list:
        for song in genre:
            labeled_lyrics.append(song)

    # shuffle the songs to prepare for creating training and test data sets
    random.shuffle(labeled_lyrics)

    return labeled_lyrics # list of tuples


## GET DATA

# make list of genres to be used in analysis
genres = ['r-and-and-b-hip-hop', 'country', 'christian', 'pop', 'rock']

# print the time right before the get_data function runs
print('Starting function to get data at ' + str(datetime.datetime.now()))

# Run the main function that returns labeled lyrics for every genre between the years 2009 and 2017
labeled_lyrics_combined = []
for year in range(2009,2018):
    labeled_lyrics_combined.append(get_data(genres, year))

# print the time right after the get_data function runs
print('Finished running function to get data at ' + str(datetime.datetime.now()))

# remove tuples of lyrics and genre from their year lists and place into single list for analysis
final_labeled_lyrics = []
failed_response = ['sorry','didnt','mean','happen']  # failed response due to an incorrect Genius URL
for year in labeled_lyrics_combined:
    for tuple in year:
        # if there is a failed response, remove from list
        if tuple[0] != failed_response:
            final_labeled_lyrics.append(tuple)


## FEATURE ENGINEERING

# create a set of all words used in the songs
song_list = [x[0] for x in final_labeled_lyrics]
# remove song words and genre from their song lists and place into list of words
word_list = []
#lemmatizer = WordNetLemmatizer()
for song in song_list:
    for word in song:
        #lemmatizer.lemmatize(word)
        word_list.append(word)
words = set(word_list)

# select the top 2000 most frequently used words
word_dist = nltk.FreqDist(word_list)
top_words = word_dist.most_common(2000)

# select the least 2000 most frequently used words
#unique_words = word_dist.most_common()[-2000:]

# create features
word_features = [tuple[0] for tuple in top_words]  # 2000 most frequent words in songs
#bigram_features = list(nltk.bigrams(word_features))  # bigrams of 2000 most frequent words
#unique_word_features = [tuple[0] for tuple in unique_words]  # 2000 most infrequently used words in songs

# define feature extractor for Naive Bayes classifier using word_features
def nb_document_features(song):
    song_words = set(song)
    #word_count = len(song)
    features = {}
    for word in word_features:
        features['contains({})'.format(word)] = (word in song_words)
    #for word in unique_word_features:
        #features['contains({})'.format(word)] = (word in song_words)
    #features['word_count'] = word_count
    return features

# define feature extractor for Naive Bayes classifier using word features & bigram features
#def document_features(song):
#    song_words = set(song)
#    song_bigrams = list(nltk.bigrams(song))
#    features = {}
#    for word in word_features:
#        features['contains({})'.format(word)] = (word in song_words)
#    for bigram in bigram_features:
#        features['contains({})'.format(bigram)] = (bigram in song_bigrams)
#    return features

# define feature extractor for XGBoost classifier using count of word features
def xgb_document_features(song):
    features = {}
    # initialize a dict with the 2000 word features and counts of zero
    for word in word_features:
        features[word] = 0
    # count words in the song
    counter = Counter()
    for word in song:
        counter[word] += 1
    # updated the initialized dict with the word counts from the song
    features.update(counter)
    # remove the words that were in the song but not in the original 2000 word list
    features = {word_feature: features[word_feature] for word_feature in word_features}
    return features


## TRAINING AND TESTING THE MODELS

## Naive Bayes

#  create features using the nb feature extractor
featuresets = [(nb_document_features(d), c) for (d, c) in final_labeled_lyrics]
size = int(len(featuresets) * 0.7)
train_set, test_set = featuresets[size:], featuresets[:size]
classifier = nltk.NaiveBayesClassifier.train(train_set)

# check accuracy of the Naive Bayes model
nltk.classify.accuracy(classifier, test_set)


## Decision Tree
classifier2 = nltk.DecisionTreeClassifier.train(train_set)
nltk.classify.accuracy(classifier2, test_set)


## XGBoost

# create features using the xgb feature extractor
featuresets = [(xgb_document_features(d), c) for (d, c) in final_labeled_lyrics]

# change structure of features into a numpy ndarray in order to train and test XGBoost model...

# create array of labels
labels = []
for tuple in featuresets:
    labels.append(tuple[1])
labels = np.array(labels)
# create array of word feature count values
values = []
for tuple in featuresets:
    word_counts = list(tuple[0].values())
    values.append(word_counts)
values = np.array(values)

# prepare test and train data for XGBoost
seed = 7
test_size = 0.30
value_train, value_test, label_train, label_test = train_test_split(values, labels, test_size=test_size, random_state=seed)

# train the XGBoost model
model = XGBClassifier()
model.fit(value_train, label_train)

# make predictions for the test data
predictions = model.predict(value_test)

# evaluate predictions
accuracy = accuracy_score(label_test, predictions)
print(accuracy)






### TESTING DISTRIBUTION OF SONG GENRES
# distribution
song_genres = []
for tuple in final_labeled_lyrics:
    song_genres.append(tuple[1])
genre_dist = nltk.FreqDist(song_genres)

# remove tuples of lyrics and genre from their year lists and place into single list for analysis
final_labeled_lyrics_2 = []
for year in labeled_lyrics_combined:
    for tuple in year:
        final_labeled_lyrics_2.append(tuple)

song_genres_2 = []
for tuple in final_labeled_lyrics_2:
    song_genres_2.append(tuple[1])
genre_dist_2 = nltk.FreqDist(song_genres_2)