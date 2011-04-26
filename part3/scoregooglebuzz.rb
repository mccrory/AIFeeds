require File.expand_path(File.dirname(__FILE__)) + '/parsejson'

def googlebuzz_count_for_url(address)
  url = "http://www.google.com/buzz/api/buzzThis/buzzCounter?url=#{address}"
  data = download_json(url)
  return 0 if data.nil?
  # google_buzz_set_count( and );
  data = data[22...-3]
  rs = parse_json(data)
  return 0 if rs.nil? or rs[address].nil?
  return rs[address].to_i
end

if __FILE__ == $0
  rs = googlebuzz_count_for_url("http://www.google.com")
  puts "google buzz google: #{rs}"
end