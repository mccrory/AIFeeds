require 'thread'

require File.expand_path(File.dirname(__FILE__)) + '/scoredelicious'
require File.expand_path(File.dirname(__FILE__)) + '/scoredigg'
require File.expand_path(File.dirname(__FILE__)) + '/scorefacebook'
require File.expand_path(File.dirname(__FILE__)) + '/scoregoogle'
require File.expand_path(File.dirname(__FILE__)) + '/scoregooglebuzz'
require File.expand_path(File.dirname(__FILE__)) + '/scorereddit'
require File.expand_path(File.dirname(__FILE__)) + '/scorestumbleupon'
require File.expand_path(File.dirname(__FILE__)) + '/scoretwitter'

SOURCES = 7
WAIT = 1

def score_url(url)
  q_out = Queue.new
  Thread.new { q_out << delicious_count_for_url(url)}
  # Thread.new { q_out << digg_count_for_url(url)} # too slow and useless
  Thread.new { q_out << facebook_count_for_url(url)}
  Thread.new { q_out << google_count_for_url(url)}
  Thread.new { q_out << googlebuzz_count_for_url(url)}
  Thread.new { q_out << reddit_count_for_url(url)}
  Thread.new { q_out << stumbleupon_count_for_url(url)}
  Thread.new { q_out << twitter_count_for_url(url)}
  # wait to finish 
  begin    
    sleep(WAIT)
    puts " >> waiting until finish scoring url (#{q_out.size}/#{SOURCES})..." if q_out.size != SOURCES 
  end while q_out.size != SOURCES  
  # sum scores
  sum = 0
  sum += q_out.pop
  return sum
end


if __FILE__ == $0
  puts "Score for google.com: #{score_url("http://www.google.com")}"
  puts "Score for cleveralgorithms.com: #{score_url("http://www.cleveralgorithms.com")}"
end