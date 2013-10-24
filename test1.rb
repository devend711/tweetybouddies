require 'rubygems'
require 'twitter' #for easy tweet fetching
require 'open-uri' #for making any GET request
require 'crack' #parses xml/json to hashes

load 'oauth_creds.rb' #hide oauth credentials
creds = MyOauth.new

Twitter.configure do |config|
  config.consumer_key =  creds.consumer_key
  config.consumer_secret = creds.consumer_secret
  
  #Applications that make requests on behalf of multiple Twitter users should avoid using global configuration
  
  #config.oauth_token = creds.oauth_token
  #config.oauth_token_secret = creds.oauth_token_secret
  
end

username_1 = "BarackObama"
fetched_user = Twitter.user(username_1)
fetched_timeline = Twitter.user_timeline(username_1)
fetched_timeline.each {|a| puts a.text + "\n\n"}

#THREADED REQUESTS
#use when application deals with multiple users for security

me = Twitter::Client.new(
  :oauth_token => creds.oauth_token,
  :oauth_token_secret => creds.oauth_token_secret
)

my_timeline = Thread.new{me.user_timeline}

#SEARCHING (see https://dev.twitter.com/docs/using-search, https://dev.twitter.com/docs/api/1.1/get/search/tweets)
#search for 10 popular/recent tweets containing "pizza" , not counting retweets

Twitter.search("pizza -rt", :count=>10, :result_type=>"mixed", :lang=>"en").results.map do |status|
	puts "#{status.from_user}: #{status.text}\n\n"
end

#GEO DATA
#use 'geocode' parameter, which takes the input "latitude,longitude,radius"
#radius can be in mi or km, e.g. 5mi
#status.geo returns Twitter::Geo::Point class

long = "42.3581"
lat = "71.0636"
rad = "10mi"
location = long+","+lat+","+rad

Twitter.search("", :count=>10, :geocode=>location).results.map do |status|
	unless status.geo == nil
		puts "#{status.text} FROM #{status.geo.coordinates}\n\n"
	end
end