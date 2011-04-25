require '../part1/parserss'
require 'date'

def article_html(source, feed, article)
  b = ""
  b << "<div style='border-style:solid;border-width:1px;border-color:#aaa;margin:10px;padding:5px;'>\n"
  # titles
  b << "<div>"
  b << "<a href='#{feed.url}'>#{get_title(feed)}</a> : "
  b << "<a href='#{article.url}'>#{article.title}</a> "
  b << "(<a href='#{source}'>rss</a>)"
  b <<"</div>\n"  
  # dates
  b << "<div>Published: #{article.date_published}, Updated: #{article.last_updated}</div>\n"
  # authors
  b << "<div>Authors: #{article.authors}</div>\n"
  # categories
  b << "<div>Categories: #{article.categories}</div>\n"
  # desc
  b << "<div>Description: #{article.description}</div>\n"
  # content
  b << "<div>Content:\n#{article.content}</div>\n"
  b << "</div>\n"
  return b
end

def articlelist_html(articles)
  # order, desc
  articles.sort!{|x,y| get_article_time(y[:article])<=>get_article_time(x[:article])}
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
  articles.each do |object| 
    b << article_html(object[:source], object[:feed], object[:article])
  end
  # footer
  b << "\n</body></html>"
  return b
end

def extract_articles(source, feed, start_date, end_date)
  selected = []
  feed.items.each do |article|
    time = get_article_time(article)
    if time.nil?
      puts "> Skipping article without datetime from #{get_title(feed)}"
      next
    end
    d2 = Date.parse(time.utc.strftime('%Y/%m/%d'))
    if d2<=start_date and d2>=end_date
      selected << {:source=>source,:feed=>feed,:article=>article} 
    end
  end
  return selected
end

if __FILE__ == $0
  # download and parse
  feeds = parse_feeds_from_file("curated_feeds.txt")
  # extract all articles
  start_date, end_date = Date.today+1, Date.today-6
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