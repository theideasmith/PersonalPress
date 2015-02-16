import json, requests, re, os, time
from datetime import date

SOURCES = ["NYT"]


def new_york_times(topics):
        key = "8eac4eb4e55fbc7fc74d9a6898467d14:4:68857836"
        todays_date=str(date.today())
        todays_date=todays_date.split('-')
        todays_date=todays_date[0]+todays_date[1]+todays_date[2]
        nytimes_link= "http://api.nytimes.com/svc/search/v2/articlesearch.json"
        articles=[]
        for topic in topics:
                url_parameters={
                        "q":topic,
                        "fq":'subsection_name("{0}")'.format(str(topic)),
                        "begin_date":todays_date,
                        "fl":"web_url",
                        "api-key":key
                }
                response=requests.get(nytimes_link, params=url_parameters)
                response=response.text
                response_loaded=json.loads(response)
                entries=response_loaded["response"]['docs']
                for entry in entries:
                        articles.append({"topic":topic, "url":entry['web_url'], "source":"NYT"})
        return articles


SOURCE_DICT = {"NYT":new_york_times}
#print new_york_times(["middle east","europe", "technology"])