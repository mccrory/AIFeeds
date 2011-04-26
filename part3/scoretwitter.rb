require 'parsejson'

def twitter_count_for_url(address)
  url = "http://urls.api.twitter.com/1/urls/count.json?url=#{address}"
  rs = get_json(url)
  return 0 if rs.nil? or rs["count"].nil?
  return rs["count"].to_i
end

if __FILE__ == $0
  rs = twitter_count_for_url("http://www.google.com")
  puts "twitter google: #{rs}"
end