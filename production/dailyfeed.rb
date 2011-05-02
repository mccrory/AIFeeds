require 'sendemail'
require '../part3/listpopulardayarticles'

def popular_article_html(source, feed, article, score)
  b = ""
  b << "<li>"
  b << "<a href='#{article.url}'>#{article.title}</a> "
  b << "<small>"
  b << "from <a href='#{feed.url}'>#{get_title(feed)}</a> "
  b << "(#{score} points) "
  b << "[<a href='#{source}'>rss</a>]"
  b << "</small>"
  b <<"</li>\n"  
  return b
end

def articlelist_html(articles)
  # generate html
  title = "AIFeed: Popular News in Artificial Intelligence"
  b = "<html>\n"
  b << "<head>"
  b << "<meta http-equiv='charset' content='text/html;charset=UTF-8' />\n"  
  b << "<title>#{title}</title>\n"
  b << "</head>\n"
  b << "<body>\n"
  b << "<h1>#{title}</h1>\n"
  b << "<p>Visit the project at <a href='https://github.com/jbrownlee/AIFeeds'>AIFeeds</a>.</p>\n"  

  # remaining
  today = Date.today
  (1..3).each do |i|
    date = today-i
    title = "#{date.strftime('%A %d %B %Y')}"
    title = "#{title} (Yesterday)" if i==1
    b << "<div style='border-style:solid;border-width:1px;border-color:#aaa;margin:10px;padding:5px;'>\n"
    b << "<h2>#{title}</h2>"
    matches = get_stories_on_day(articles, date)
    if matches.empty?
      b << "None"
    else
      # sort
      pop, other = [], []
      matches.each do |a| 
        if a[:score] > 0
          pop << a
        else
          other << a
        end
      end
      # display popular
      if !pop.empty?
        b << "<h3>Popular</h3>"
        b << "<ul>\n"
        pop.sort!{|x,y| y[:score]<=>x[:score]} # descending
        pop.each do |a|
          b << popular_article_html(a[:source], a[:feed], a[:article], a[:score])
        end
        b << "</ul>\n"
      end
      # display other
      if !other.empty?
        b << "<h3>Remaining</h3>"
        b << "<ul>\n"
        other.sort!{|x,y| x[:article].title<=>y[:article].title} # asc
        other.each do |a|
          b << article_html(a[:source], a[:feed], a[:article])
        end
        b << "</ul>\n"
      end
    end
     b << "</div>\n"
  end
  
  # footer
  b << "<p>Got an idea or suggested improvement? Reply to this email!</p>\n"
  b << "\n</body></html>"
  return b
end

def generate_and_send(gmail_email, gmail_password)
  # email list
  email_list = []
  File.open('list.txt', 'r').each_line do |line| 
    email_list << line.strip if !line.nil? and !line.strip.empty?
  end
  # download and parse
  feeds = parse_feeds_from_file("../part2/curated_feeds.txt")
  # extract all articles
  start_date, end_date = Date.today, Date.today-6
  articles = []
  feeds.each do |object|
    list = extract_articles(object[:source], object[:feed], start_date, end_date)
    list.each {|a| articles << a }
  end  
  # generate html
  html = articlelist_html(articles)
  # create smtp message
  message = build_message("Daily AIFeed", "AIFeed", gmail_email, "You", gmail_email, html, true)
  # send email
  send_email_gmail(gmail_email, gmail_password, message, gmail_email, gmail_email, email_list)
end

if __FILE__ == $0
  # params
  if ARGV.length != 2
  	puts "Usage: ruby dailyfeed.rb <gmail email address> <gmail password>"
  	exit
  end  
  # collect details
  myemail = ARGV[0]
  password = ARGV[1]
  # do it
  generate_and_send(myemail, password)  
  puts "done"
end
