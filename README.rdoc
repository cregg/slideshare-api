== README

# Slideshare Back End

Hi all. I've kind of hacked this together. So if you try and break it, I'm sure you'll be able to. 

Hosted @ https://slideshare-backend.herokuapp.com.

The front end built to access the back end can be found @ https://slideshare-frontend.herokuapp.com.

## Endpoints

### /search/create

POST company name, company url to this endpoint in order to start your search for docs. 

### /search/{hash}

GET from this endpoint returns a hash containing the search status, important company employees, company key words, and docs. 

### /sidekiq

Background Job interface

## Issues:

Slideshare Access: Slideshare throttles my number of searches in a day. That caused me a few problems. Extensive use of this app will cause it fail. 

Speed: It's can be pretty slow parsing and ranking the documents.

### Suggestions if I were to continue further improving this application

Use Concurrency to retrieve SlideShare documents + Use Concurrency to parse the docs as well.

Use LinkedIn API to search for further employees of the company (This requires permission from LinkedIn after a review of your app).