require 'rubygems'
require 'bundler'
require 'ostruct'
require 'erubis'

JSON_FILE = "./article.json"



LOCATION = "/Developer/Code/HackCooper"

Bundler.require(:default)
puts Dir.pwd
Dir.chdir Dir.pwd


class DataGenerator
  attr_accessor :news, :articles_arr
  def reset 
    system "rm -rf ./images/*"
  end

  def json_to_array(json)
    if File.exists? json
      puts "file exists"
      file = File.open json, "rb"
      contents = file.read.chomp
      JSON.parse(contents)
    end

  end

  def capture_news_elements news_array
    begin_location = Dir.pwd

    agent = Mechanize.new
    news_array.each do |item|
      img_url = item["IMG_URL"]
      if img_url
        article_name = item["TITLE"]
        image = agent.get img_url
        image.save_as "./images/#{article_name}.jpg"
      end
    end

    system "cd #{begin_location}"
  end

  def initialize json
    self.reset
    @news = []
    @articles_arr = []
    data = self.json_to_array json
    data.each do |data|
        item = data
        @news <<item
    end
    capture_news_elements @news
    index = 1
    @news.each do |item|
      hash = {}
        item.keys.each do |k|
          hash[k.downcase] = item[k]
        end
      hash["float"] = index %2==0 ? "right": "left"

      @articles_arr << OpenStruct.new(hash)
      index +=1
    end

  end
  def self.assemble_articles json
    articles = DataGenerator.new(json)
    articles.articles_arr
  end
end



@articles = DataGenerator.assemble_articles JSON_FILE
Tilt.prefer Tilt::ErubisTemplate
template = Tilt.new('./templates/article.html.erb', :escape_html => false)
html = template.render(self, :articles=>@articles)

File.new("htmlTest.html", "w+")
htmlFile = File.open("htmlTest.html", "a+")
htmlFile.puts html.chomp
