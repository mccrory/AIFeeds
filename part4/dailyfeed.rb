require 'sendemail'
require '../part3/listpopulardayarticles'

def generate_and_send(gmail_email, gmail_password)
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
  send_email_gmail(gmail_email, gmail_password, message, gmail_email, gmail_email)
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
