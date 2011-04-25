require "rexml/document"
include REXML

def extract_rss_from_opml(filename)
  # open
  file = File.new(filename)
  # parse
  doc = Document.new(file)
  # process each outline
  feeds = []
  doc.elements.each("//outline[@type='rss']") do |element|
    feeds << element.attribute("xmlUrl").value
  end
  return feeds
end

if __FILE__ == $0
  # list of opml
  opml_files = ["opml/Yaroslav-Bulatov.xml", "opml/jason-brownlee.xml", 
    "opml/machine-learning.xml", "opml/sandrosaitta.opml"]
  # extract the rss feeds from each
  feeds = []
  opml_files.each do |filename|
    puts " > extracting rss feeds from #{filename}"
    list = extract_rss_from_opml(filename)
    list.each {|feed| feeds<<feed}
  end
  # write file
  filename = "opml_feeds.txt"
  File.open(filename, 'w') {|f| f.write(feeds.join("\n"))}
  puts "Successfully wrote #{feeds.size} rss feeds to #{filename}"
end