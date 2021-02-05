### Python Web Scraper tutorial ###

# Introduce myself

# Talk about my use case for web scraping and show my slides at a high level

# Explain that today we will be just taking one element of this use case scraping one Billboard top hits page
# for song artists and titles, and then taking that data and scraping Genius's website for songs lyrics

# Set up Python environment - show them PyCharm and how easy it is to set up a new environment
# Install requests and bs4

import requests
from bs4 import BeautifulSoup

# go to the billboard 2019 hit pop songs page - copy the URL into the code

url = "https://www.billboard.com/charts/year-end/2019/pop-songs"
response = requests.get(url)

# talk briefly about a request and response - show that the response is a 200

page_content = BeautifulSoup(response.text, 'html.parser') # creates a parse tree that can be used to extract data from HTML

# show the difference between what is in "response" and what is in "page_content"
# pull up the BeautifulSoup documentation as needed (google it)

# next, we need to find a way to get just what we want (artist names and song titles) from the page_content
# this is where selector gadget comes in

# explain selector gadget - installing it, and using it

artists_div = page_content.select(".ye-chart-item__artist")
artists = [artist.text for artist in artists_div] # list comprehension - a pythonic way to do a "for loop"

# reminder - this is how it would look with a for loop:
# i=0
# artists_ex = []
# for artist in artists_div:
#     artist = artist.text
#     artists_ex.append(artist)
#     i += 1

artists = [artist.strip('\n') for artist in artists]

# next, scrape titles

titles = page_content.select(".ye-chart-item__title")
titles = [title.text for title in titles]
titles = [title.strip('\n') for title in titles]

# we now should have what we need to create genius URLs

# create genius URLs
i = 0
genius_urls = []
for song in artists:
    genius_url = 'https://genius.com/' + artists[i] + '-' + titles[i] + '-lyrics'
    genius_urls.append(genius_url)
    i += 1

# let's take a look now at the URLs - what problems do we see? let's try and fix a few

##### clean up artists and titles and recreate genius URLs

##### scrape the Genius URLs

#### do some cleaning of the lyrics (remove punctuation, tokenize, remove stop words)

#### if there is time, show how some features can be created

#### if there is even MORE time, show how to run a classifier