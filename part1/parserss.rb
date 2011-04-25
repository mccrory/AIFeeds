require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'timeout'
require 'thread'

TIMEOUT=15 # socket timeout in seconds
THREADS=8 # number of threads for IO workers

# parse a single feed
def parse_feed(source)
  begin
    Timeout::timeout(TIMEOUT) do
      # open stream
      stream = nil
      begin
        stream = open(source)
      rescue => e
        puts "Error opening '#{source}': #{e.to_s}"
        return nil
      end
      # download and parse
      feed = nil
      begin
        feed = FeedNormalizer::FeedNormalizer.parse(stream)
      rescue => e
        puts "Error downloading/parsing '#{source}': #{e.to_s}"
        return nil
      end
      return feed
    end
  rescue Timeout::Error => e
     puts "Timeout opening '#{source}': #{e.to_s}"
  end
end

# parse all feeds in the input queue and write the results to the output queue as a hash
def parse_feeds(q_in, q_out)  
  Thread.new do
    begin
      # parse
      source = q_in.pop
      feed = parse_feed(source)
      # add if any data
      if !feed.nil?
        q_out.push({:source=>source,:feed=>feed})
        puts "> parsed #{source}"
      else 
        puts "> failed to connect to #{source}"
      end
    end while !q_in.empty?
  end
end

# parse all feeds from file and return a queue of hashes
def parse_feeds_from_file(filename)
  raw_feeds = filename.is_a?(Array) ? filename : [filename]
  q_in=Queue.new
  q_out=Queue.new
  # load all feeds into the input queue
  raw_feeds.each do |file|
    File.open(file, 'r').each_line do |line| 
      q_in.push(line.strip) if !line.nil? and !line.strip.empty?
    end
  end
  # download and parse all rss 
  THREADS.times { parse_feeds(q_in, q_out) }
  # wait to finish 
  begin
    puts " >> waiting to finish processing feeds..."
    sleep(10)
  end while !q_in.empty?
  feeds = []
  feeds << q_out.pop while !q_out.empty?
  return feeds
end

def get_title(feed)
  title = feed.title
  if title.nil?
    title = "Untitled" 
  else 
    title = title.strip
    title = "Untitled" if title.empty?
  end
  return title
end

def get_article_time(article)
  date = article.last_updated
  date = article.date_published if date.nil?
  return date
end


if __FILE__ == $0
  # parse feed
  url = "http://www.damienfrancois.be/blog/atom.xml"
  o = parse_feed(url)
  # display details
  puts "#{o.title} at #{o.url}"  
  o.items.each do |item|
    puts "> #{item.title} [#{item.last_updated}]"
  end
  puts "done"
end
