load 'test2.rb'
require 'geocoder' #for coordinate lookups

#CoordLookup can return a lat/long based on a search term or IP Adress, or an Address based on these things

class CoordLookup
  def initialize(term = nil, long = nil, lat = nil)
	@term = term
	@long = 0
	@lat = 0
  end
  
  def get_coords
  	s = Geocoder.search(@term)
  	@lat = s[0].latitude.to_s()
  	@long = s[0].longitude.to_s()
  	{:lat => @lat, :long => @long}
  end
  
  def get_name
  	s = Geocoder.search("#{@lat}, @{@long}")
  	@name = s[0].address
  end
  
end

lookup1 = CoordLookup.new("Pyramids of Giza")
tweetsearch1 = TweetSearch.new(lookup1.get_coords[:lat],lookup1.get_coords[:long], :name => lookup1.get_name, :radius => 10)
search1 = SearchResults.new(tweetsearch1,GetTemplate())
search1.save('examplesearch.html')