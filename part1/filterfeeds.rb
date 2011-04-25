require 'parserss'

def filter_feeds(feeds)
  filtered = {}
  feeds.each do |object|
    source,feed = object[:source], object[:feed]
    address = feed.url
    if address.nil? or (address=address.strip).empty?
      puts "> feed does not have known address #{address}"
      next
    end
    if filtered.has_key?(address)
      puts "> duplicate for #{address}, skipping #{source}"
    else
      filtered[address] = source
      puts "> added #{source} for #{address}"
    end
  end
  return filtered
end

def write_filtered_feeds(filtered, filename)
  File.open(filename, 'w') do |f| 
    filtered.keys.each do |key|
      f.write("#{filtered[key]}\n") 
    end
  end
  puts "Wrote #{filtered.size} filted feeds to #{filename}"
end

if __FILE__ == $0
  feeds = parse_feeds_from_file(["opml_feeds.txt", "byhand_feeds.txt"])
  # filter feeds
  filtered = filter_feeds(feeds)
  # write out
  write_filtered_feeds(filtered, "filtered_feeds.txt")
end