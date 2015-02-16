from flask import request, Flask, jsonify
import json

import urllib2
import goose
import cookielib
import requests
import BeautifulSoup
import getArticleURLs
import json
import os

# all of these return [TOPIC, SOURCE, TITLE, CONTENT, IMG_URL, AUTHOR]
def get_nytimes_article(source, topic, url):
	headers = {}
	headers['User-Agent'] = "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.27 Safari/537.17"
	response_text = requests.get(url, headers=headers).content
	soup = BeautifulSoup.BeautifulSoup(response_text)
	authors = soup.findAll(attrs={'class':'byline-author'})
	author = ' and '.join([i.text for i in authors])
	lines = soup.findAll(attrs={'class':"story-body-text story-content"})
	cleaned_text = ''.join([i.text for i in lines])
	title = soup.title.text[:-14]

	#get the article picture via google image search:
	headers = {}
	headers['User-Agent'] = "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.27 Safari/537.17"
	formatted_title = title.encode('ascii', 'ignore')
	response_text = requests.get('http://www.google.com/search?hl=en&authuser=0&site=imghp&tbm=isch&source=hp&biw=1366&bih=600&q={0}'.format(formatted_title), headers=headers).content
	soup = BeautifulSoup.BeautifulSoup(response_text)
	images = soup.findAll(attrs={'class':"rg_di rg_el"})
	raw_image_text = str(images[0])
	image_url = raw_image_text[raw_image_text.find("imgurl=")+7:raw_image_text.find("&amp")]
	return [topic, source, title, cleaned_text, image_url, author] #return the content


def get_goose_article(source, topic, url):
	g = goose.Goose()
	article = g.extract(url=url)
	cleaned_text =  article.cleaned_text
	img_src = article.top_image.src
	title = article.title
	return [topic, source, title, cleaned_text, img_src, ""]

def get_article_content(source, topic, url):
	if source == "NYT":
		return get_nytimes_article(source,topic, url)
	else:
		return get_goose_article(source,topic, url)

def combine_sources(topics):
	if len(getArticleURLs.SOURCES) == 1:
		return getArticleURLs.SOURCE_DICT[getArticleURLs.SOURCES[0]](topics)
	else:
		return [SOURCE_DICT[source](topics) for source in getArticleURLs.SOURCES]

def make_JSON_file(data):
	#format of data: [{topic="", url="", source=""}, {topic="", url="", source=""}]
	result = []
	for article in data: #{topic="", url="", source=""}
		print 'article!'
		topic = article["topic"]
		url = article["url"]
		source = article["source"]
		article_content = get_article_content(source, topic, url) #[TOPIC, SOURCE, TITLE, CONTENT, IMG_URL]

		d = {"TOPIC":topic,
			 "SOURCE":source,
			 "TITLE":article_content[2].encode('ascii', 'ignore'),
			 "CONTENT":article_content[3].encode('ascii', 'ignore'),
			 "IMG_URL":article_content[4],
			 "AUTHOR":article_content[5].encode('ascii', 'ignore')}
		result.append(d)
	with open('information.json','wb') as info:
		json.dump(result,info)

def main(topics):
	print "recieved topics"
	data = combine_sources(topics)
	print 'made data'
	make_JSON_file(data)
	print "made file, sending to ruby"
	os.system("ruby main.rb")
	print " sent to ruby"


app = Flask(__name__)

@app.route('/topics', methods = ['GET', "POST"])
def api_echo():
	if True:
		a = str(request.args)
		b = eval(a[19:-1])
		topic_list = [i[1] for i in b if i[0]=='topics[]']
		main(topic_list)
		return 'Hello' 
	else:
		return 'Hello John Doe'
if __name__ == '__main__':
	app.run()