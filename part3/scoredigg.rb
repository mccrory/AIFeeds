require 'parsejson'

def digg_details_for_url(address)
  url = "http://widgets.digg.com/buttons/count?url=#{address}"
  data = download_json(url)
  return 0 if data.nil?
  # skip __DBW.collectDiggs( and );
  data = data[19...data.size-2]
  rs = parse_json(data)
  return 0 if rs.nil? or rs["diggs"].nil?
  return rs["diggs"].to_i
end

if __FILE__ == $0
  rs = digg_details_for_url("http://www.google.com")
  puts "digg google: #{rs}"
end
