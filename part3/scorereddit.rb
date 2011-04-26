require 'parsejson'

def reddit_count_for_url(address)
  url = "http://www.reddit.com/api/info.json?url=#{address}"  
  result = get_json(url)
  return 0 if result.nil? or result["data"].nil? or result["data"]["children"].nil?
  rs = {}
  rs[:posts] = result["data"]["children"].size
  rs[:score], rs[:ups], rs[:downs], rs[:comments] = 0, 0, 0, 0
  result["data"]["children"].each do |post|
    rs[:score] += post["data"]["score"].to_i
    rs[:ups] += post["data"]["ups"].to_i
    rs[:downs] += post["data"]["downs"].to_i
    rs[:comments] += post["data"]["num_comments"].to_i
  end
  return rs[:posts] + rs[:score] + rs[:comments]
end


if __FILE__ == $0
  rs = reddit_count_for_url("http://www.google.com")
  puts "reddit google: #{rs}"
end