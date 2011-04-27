require 'rubygems'
require 'feed-normalizer'
require 'open-uri'
require 'timeout'
require 'thread'


# fix: Blogspot feeds (atom) now have wrong post permalink
# Regarding: http://code.google.com/p/feed-normalizer/issues/detail?id=30
# from https://github.com/aldavidson/simple-rss
# more specifically: https://github.com/aldavidson/simple-rss/blob/master/lib/simple-rss.rb
class SimpleRSS
  def parse
    raise SimpleRSSError, "Poorly formatted feed" unless m = %r{<(channel|feed).*?>.*?</(channel|feed)>}mi.match(@source)

    # Feed's title and link
    feed_content = m[1] if  m = %r{(.*?)<(rss:|atom:)?(item|entry).*?>.*?</(rss:|atom:)?(item|entry)>}mi.match(@source)

    @@feed_tags.each do |tag|
      m = %r{<(rss:|atom:)?#{tag}(.*?)>(.*?)</(rss:|atom:)?#{tag}>}mi.match(feed_content) ||
          %r{<(rss:|atom:)?#{tag}(.*?)\/\s*>}mi.match(feed_content)  ||
          %r{<(rss:|atom:)?#{tag}(.*?)>(.*?)</(rss:|atom:)?#{tag}>}mi.match(@source) ||
          %r{<(rss:|atom:)?#{tag}(.*?)\/\s*>}mi.match(@source)

      if m && (m[2] || m[3])
        tag_cleaned = clean_tag(tag)
        instance_variable_set("@#{ tag_cleaned }", clean_content(tag, m[2],m[3]))
        self.class.send(:attr_reader, tag_cleaned)
      end
    end

    # RSS items' title, link, and description
    @source.scan( %r{<(rss:|atom:)?(item|entry)([\s][^>]*)?>(.*?)</(rss:|atom:)?(item|entry)>}mi ) do |match|
      item = Hash.new
      @@item_tags.each do |tag|
        if tag.to_s.include?("+")
          tag_data = tag.to_s.split("+")
          tag = tag_data[0]
          rel = tag_data[1]

          m = %r{<(rss:|atom:)?#{tag}(.*?)rel=['"]#{rel}['"](.*?)>(.*?)</(rss:|atom:)?#{tag}>}mi.match(match[3]) ||
              %r{<(rss:|atom:)?#{tag}(.*?)rel=['"]#{rel}['"](.*?)/\s*>}mi.match(match[3])
          item[clean_tag("#{tag}+#{rel}")] = clean_content(tag, m[3], m[4]) if m && (m[3] || m[4])
        else
          m = %r{<(rss:|atom:)?#{tag}(.*?)>(.*?)</(rss:|atom:)?#{tag}>}mi.match(match[3]) ||
              %r{<(rss:|atom:)?#{tag}(.*?)/\s*>}mi.match(match[3])
          item[clean_tag(tag)] = clean_content(tag, m[2],m[3]) if m && (m[2] || m[3])
        end
      end

      # Hack to fix blogspot atom feed links pointing to comments issue
      # Looks like the code here is just taking the FIRST link tag and using
      # the href from that. In Blogspot atom feeds, this tends to be the link
      # to the comments - not what we want.
      # The RFC (http://www.ietf.org/rfc/rfc4287.txt) states that
      # 'atom:link elements MAY have a "rel" attribute that indicates the link
      # relation type.  If the "rel" attribute is not present, the link
      # element MUST be interpreted as if the link relation type is
      # "alternate"'
      # Therefore we can work backwards and infer that the 'alternate' link,
      # if present, should be taken as the default.
      if item[:'link+alternate']
        item[:link] = item[:'link+alternate']
      end

      def item.method_missing(name, *args) self[name] end

      @items << item
    end
  end
end


RSS_TIMEOUT=15 # socket timeout in seconds
THREADS=8 # number of threads for IO workers

# parse a single feed
def parse_feed(source)
  begin
    Timeout::timeout(RSS_TIMEOUT) do
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
