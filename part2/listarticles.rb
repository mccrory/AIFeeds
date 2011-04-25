require '../part1/parserss'
require 'viewarticles'

def article_html(source, feed, article)
  b = ""
  b << "<li>"
  b << "<a href='#{article.url}'>#{article.title}</a> from "
  b << "<small>"
  b << "<a href='#{feed.url}'>#{get_title(feed)}</a> "
  b << "[<a href='#{source}'>rss</a>]"
  b << "</small>"
  b <<"</li>\n"  
  return b
end

def same_day?(d1, time)
  d2 = Date.parse(time.utc.strftime('%Y/%m/%d'))
  return false if d1.year != d2.year
  return false if d1.month != d2.month
  return false if d1.day != d2.day
  return true
end

def get_stories_on_day(articles, day)
  matches = []
  articles.each do |object|
    datetime = get_article_time(object[:article])
    matches << object if same_day?(day, datetime)
  end
  return matches
end

def articlelist_html(articles)
  # generate html
  title = "AIFeed: List of Recent Articles"
  b = "<html>\n"
  b << "<head>"
  b << "<meta http-equiv='charset' content='text/html;charset=UTF-8' />\n"  
  b << "<title>#{title}</title>\n"
  b << "</head>\n"
  b << "<body>\n"
  b << "<h1>#{title}</h1>\n"
  b << "<p>Visit the project at <a href='https://github.com/jbrownlee/AIFeeds'>AIFeeds</a>.</p>\n"  
  # body
  today = Date.today
  (0...7).each do |i|
    date = today-i
    title = "#{date.strftime('%A %d %B %Y')}"
    title = "#{title} (Today)" if i==0
    title = "#{title} (Yesterday)" if i==1
    b << "<div style='border-style:solid;border-width:1px;border-color:#aaa;margin:10px;padding:5px;'>\n"
    b << "<h2>#{title}</h2>"
    matches = get_stories_on_day(articles, date)
    if matches.empty?
      b << "None"
    else
      b << "<ul>\n"
      matches.each do |object| 
        b << article_html(object[:source], object[:feed], object[:article])
      end
      b << "</ul>\n"
    end
     b << "</div>\n"
  end
  # footer
  b << "\n</body></html>"
  return b
end

if __FILE__ == $0
  # download and parse
  feeds = parse_feeds_from_file("curated_feeds.txt")
  # extract all articles
  start_date, end_date = Date.today, Date.today-6
  articles = []
  feeds.each do |object|
    list = extract_articles(object[:source], object[:feed], start_date, end_date)
    list.each {|a| articles<<a }
  end  
  # generate html
  html = articlelist_html(articles)
  # write
  filename = "articlelist.html"
  File.open(filename, 'w') {|f| f.write(html)}
  puts "Successfully wrote recent articles to #{filename}"
end