require 'parserss'

def feedsource_html(source, feed)
  b = ""
  b << "<a href='#{feed.url}'>#{feed.title}</a>"
  b << "&nbsp;"
  b << "(<a href='#{source}'>rss</a>)"
  return b
end

def feedlist_html(feeds)
  # order
  feeds.sort!{|x,y| get_title(x[:feed]).downcase<=>get_title(y[:feed]).downcase}
  # generate html
  title = "AIFeed: List of Feeds"
  b = "<html>\n"
  b << "<head>"
  b << "<meta http-equiv='charset' content='text/html;charset=UTF-8' />\n"  
  b << "<title>#{title}</title>\n"
  b << "</head>\n"
  b << "<body>\n"
  b << "<h1>#{title}</h1>"
  b << "<p>Visit the project at <a href='https://github.com/jbrownlee/AIFeeds'>AIFeeds</a>.</p>"  
  # body
  b << "<ul>\n"
  feeds.each do |object| 
    b << "<li>#{feedsource_html(object[:source],object[:feed])}</li>"
  end
  b << "</ul>\n"
  # footer
  b << "</body></html>"
  return b
end

if __FILE__ == $0
  # download and parse
  feeds = parse_feeds_from_file("filtered_feeds.txt")
  # generate html
  html = feedlist_html(feeds)
  # write
  filename = "feedlist.html"
  File.open(filename, 'w') {|f| f.write(html)}
  puts "Successfully wrote #{feeds.size} rss feeds to #{filename}"
end