require 'parsejson'

def google_count_for_url(address)
  url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{address}&rsz=small"
  rs = get_json(url)
  return 0 if rs.nil? or rs['responseData'].nil? or rs['responseData']['cursor'].nil?
  return 0 if rs['responseData']['cursor']['estimatedResultCount'].nil?
  return rs['responseData']['cursor']['estimatedResultCount'].to_i
end

if __FILE__ == $0
  rs = google_count_for_url("http://www.google.com")
  puts "reddit google: #{rs}"
end