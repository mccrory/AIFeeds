require 'parsejson'
require 'digest/md5'

def delicious_count_for_url(address)
  digest = Digest::MD5.hexdigest(address)
  url = "http://feeds.delicious.com/v2/json/urlinfo/blogbadge?hash=#{digest}"  
  rs = get_json(url)
  return 0 if rs.nil? or rs.empty? or rs[0]["total_posts"].nil?
  return rs[0]["total_posts"].to_i
end

if __FILE__ == $0
  rs = delicious_count_for_url("http://www.google.com")
  puts "delicious google: #{rs}"
end