require 'parsejson'

def stumbleupon_count_for_url(address)
  url = "http://www.stumbleupon.com/services/1.01/badge.getinfo?url=#{address}"
  rs = get_json(url)
  return 0 if rs.nil? or rs["result"].nil? or rs["result"]["views"].nil?
  return rs["result"]["views"].to_i
end

if __FILE__ == $0
  rs = stumbleupon_count_for_url("http://www.google.com")
  puts "stumbleupon google: #{rs}"
end
