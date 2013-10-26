require 'rubygems'
require 'twitter' #for easy tweet fetching
require 'open-uri' #for making any GET request
require 'crack' #parses xml/json to hashes
require 'erb'

load 'oauth_creds.rb' #hide oauth credentials
creds = MyOauth.new

Twitter.configure do |config|
  config.consumer_key =  creds.consumer_key
  config.consumer_secret = creds.consumer_secret
  
  #Applications that make requests on behalf of multiple Twitter users should avoid using global configuration
  
  config.oauth_token = creds.oauth_token
  config.oauth_token_secret = creds.oauth_token_secret
  
end


def GetTemplate()

  %{
    <DOCTYPE html  "-//W3C//DTD  1.0 //EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <title>Tweets within <%= @rad %><%= @unit %> of <%= @lat %>, <%= @long %></title>
        </head>
        <body>
                 <h1>Results within <%= @rad %><%= @unit %> of <%= @lat %>, <%= @long %></h1>
                <ul>
                  <% @tweetlist.each do |item| %>
     				<li><%= item[:text] %></li>
                  <% end %>
                </ul>
        </body>
        </html>
  }
  
end

class TweetSearch

	attr_accessor :long, :lat, :rad, :unit, :count, :text, :tweetlist

	def initialize(long,lat,rad,unit="mi",count=10,text="")
		@long = long
		@lat = lat
		@rad = rad
		@unit = unit
		@location = @long+","+@lat+","+@rad+@unit
		@count = count
		@text = text
		@tweetlist = []
	end
	
	def list #finds tweetlist, an array of hashes
		@tweetlist = []
		Twitter.search(@text, :count=>@count, :geocode=>@location).results.map {|status|
			unless status.geo == nil
				hash = {:text=>status.text,:coord=>status.geo.coordinates}
				@tweetlist.push(hash)
			end
		}
		return @tweetlist
    end    
    
end

class SearchResults

  include ERB::Util
  attr_accessor :tweetlist, :template

  def initialize(search, template)
  	@tweetlist = search.list
	@template = template
	@long = search.long
	@lat = search.lat
	@rad = search.rad
	@unit = search.unit
  end

  def render()
    ERB.new(@template).result(binding) #binding means the template will get the vars from parent instance
  end

  def save(file)
    File.open(file, "w+") do |f|
      f.write(render)
    end
  end

end


tweetsearch1 = TweetSearch.new("42.3581","71.0636","10")
search1 = SearchResults.new(tweetsearch1,GetTemplate())
search1.save(File.join(ENV['HOME'],'examplesearch.html'))
