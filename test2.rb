require 'rubygems'
require 'twitter' #for easy tweet fetching
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

#shitcakes
def GetTemplate()

  %{
    <DOCTYPE html  "-//W3C//DTD  1.0 //EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
		 <link href="style.css" rel="stylesheet" type="text/css">
		<title>Tweets within <%= @rad %><%= @unit %> of 
			<% if @name != nil %>
				<%= @name %>
			<% else %>
				[<%= @lat %>, <%= @long %>]
			<% end %>
		</title>
	</head>
	<body>
		 <h1>Results within <%= @rad %><%= @unit %> of 
			<% if @name != nil %>
				<%= @name %>
			<% else %>
				[<%= @lat %>, <%= @long %>]
			<% end %>
		 </h1>
	 
		  <% @tweetlist.each do |item| %>
			  <div class = "cont">
					<span class = "t_box t_text">
						<%= item[:text] %>
					</span>
					<span class = "t_box t_time">
						at <%= item[:time] %>
					</span>
					<span class = "t_box t_loc">
						from <%= item[:coord] %>
					</span>
				</div>
		  <% end %>
	</body>
	</html>
  }
  
end

class TweetSearch
  attr_accessor :lat, :long, :rad, :unit, :tweetlist, :name

  DEFAULTS = {:count => 10, :text => "", :lang => "en", :name => "", :rad => "10", :unit => "mi"}

  def initialize(lat, long, options = {})
	options = DEFAULTS.merge(options) #merge default values and parameters
	@lat = lat.to_s()
	@long = long.to_s()
	@rad = options[:rad].to_s()
	@unit = options[:unit].to_s()
	@location = @long+","+@lat+","+@rad+@unit
	@tweetlist = []
  end
	
  def list #finds tweetlist, an array of hashes
	@tweetlist = []
	Twitter.search(@text, :count=>1000, :geocode=>@location, :lang => "en").results.map {|status|
		unless status.geo == nil 
			hash = {:text=>status.text,:time=>status.created_at,:coord=>status.geo.coordinates}
			@tweetlist.push(hash)
		end
	}
	return @tweetlist
  end    
end

class SearchResults

  include ERB::Util

  def initialize(search, template)
  	@tweetlist = search.list
	@template = template
	@lat = search.lat
	@long = search.long
	@rad = search.rad
	@unit = search.unit
	@name = search.name
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


tweetsearch1 = TweetSearch.new("71.0636","42.3581")
search1 = SearchResults.new(tweetsearch1,GetTemplate())
search1.save('examplesearch.html')
