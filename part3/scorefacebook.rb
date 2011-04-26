require File.expand_path(File.dirname(__FILE__)) + '/parsejson'

def facebook_count_for_url(address)
  url = "http://api.ak.facebook.com/restserver.php?v=1.0&method=links.getStats&format=json&urls=#{address}"
  rs = get_json(url)
  return 0 if rs.nil? or rs.empty? or rs[0]["total_count"].nil?
  return rs[0]["total_count"].to_i
end

if __FILE__ == $0
  rs = facebook_count_for_url("http://www.google.com")
  puts "facebook google: #{rs}"
end
