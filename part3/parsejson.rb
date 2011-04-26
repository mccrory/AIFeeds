require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'timeout'

TIMEOUT = 5

# download a url
def download_json(address)
  response = nil
  # http socket work
  begin
    Timeout::timeout(TIMEOUT) do
      begin
        # parse the address
        uri = URI.parse(address)
        # connect and download
        response = Net::HTTP.get_response(uri)
      rescue => e
        puts "Error downloading json from #{address}: #{e}"
        return nil
      end
    end
  rescue Timeout::Error => e
     puts "Timeout opening socket to '#{address}': #{e.to_s}"
     return nil
  end
  # process response if we get one
  case response
  when Net::HTTPSuccess
    # get the body
    return nil if response.body.empty?
    return response.body
  end
  puts "Unexpected response downloading json from #{address}: #{response}"
  return nil
end

# parse json
def parse_json(data)
  begin
    return JSON.parse(data)
  rescue => e
    puts "Error parsing json: #{e}"
    return nil
  end
end

# download and parse json
def get_json(address)
  data = download_json(address)
  return nil if data.nil?
  return parse_json(data)
end
