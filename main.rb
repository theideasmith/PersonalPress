require 'rubygems'
require 'bundler'
require 'ostruct'
require 'time'
 require 'date'
JSON_FILE = "./information.json"



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
    # capture_news_elements @news #Because the engine already captures the images. No need to download them on my own
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

def assemble_date 
  t = Time.new
  days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
  months=["January","February","March","April","May","June","July","August","September","October","November","December"]
  day_num = t.day
  day = ""
  case "#{day_num}"[-1,1]
  when "1"
    day = "#{day_num}st"
  when "2"
    day = "#{day_num}nd"
  when "3"
    day = "#{day_num}rd"
  else 
    day = "#{day_num}th"
  end

  "#{days[t.wday]}, #{months[t.month-1]} #{day}, #{t.year}"
end


@articles = DataGenerator.assemble_articles JSON_FILE
Tilt.prefer Tilt::ErubisTemplate
template = Tilt.new('./templates/article.html.erb', :escape_html => false)

@today = assemble_date



index = 0
last_two_lengths = [@articles[0].content.size, @articles[1].content.size ]
left_more = @articles[0].content.size > @articles[1].content.size ? true : false
prev_abs = (last_two_lengths[0]-last_two_lengths[1]).abs

articles_left = [] << @articles.shift
articles_right = [] << @articles.shift
direction = 1
until @articles.size == 0 do 

  new_article = @articles.shift
  if direction > 0
    articles_left << new_article
  else
    articles_right << new_article
  end
  direction = -direction
end
=begin
  if left_more

      articles_right << new_article
    left_more = prev_abs > new_article.content.size ? false : false
    prev_abs = (new_article.content.size-prev_abs).abs
      
  else 
  articles_right << new_article
      left_more = prev_abs > new_article.content.size ? true : false
      prev_abs = (new_article.content.size-prev_abs).abs
  end

end
=end




html = template.render(self, 
  :articles_left=>articles_left, 
  :articles_right=>articles_right, 
  :today=>@today
  )


File.new("toPDF.html", "w+")
htmlFile = File.open("toPDF.html", "a+")
htmlFile.puts html.chomp


kit = PDFKit.new(html.encode("UTF-8"), :page_size => 'Letter')
  # kit.stylesheets << './styles/app.css'

# Get an inline PDF
pdf = kit.to_pdf

# Save the PDF to a file
file = kit.to_file('./Result.pdf')
system ('lpr Result.pdf')
# system "rm toPDF.html"



