require 'digest/sha1'


class SlideshareAPI

  API_KEY = ENV['SLIDESHARE_KEY']
  API_SECRET = ENV['SLIDESHARE_SECRET']
  
  BASE_URL = 'https://www.slideshare.net/api/2/'
  SEARCH_URL = 'https://www.slideshare.net/api/2/search_slideshows'
  TAG_URL = 'https://www.slideshare.net/api/2/get_slideshows_by_tag'

  # TODO refactor to us query hash instead of ugly long string.
  def search_by_query query, page
    totalResults = []
    query = URI.escape query
    timestamp = Time.now.to_i
    secret = API_SECRET
    hash = Digest::SHA1.hexdigest (API_SECRET + timestamp.to_s)
    queryString = "https://www.slideshare.net/api/2/search_slideshows?q=#{query}&api_key=#{API_KEY}&hash=#{hash}&ts=#{timestamp.to_s}&items_per_page=50&page=#{page}&detailed=1&get_transcript=1"
    response = HTTParty.get queryString
    return response["Slideshows"]["Slideshow"]
  end

  def search_by_tag tag
    total_results = []
    timestamp = Time.now.to_i
    secret = API_SECRET
    hash = Digest::SHA1.hexdigest (API_SECRET + timestamp.to_s)
    offset = 0
    limit = 10000
    items_per_page = 100
    query = { "tag" => tag, "hash" => hash, "api_key" => API_KEY, "ts" => timestamp.to_s, "offset" => offset, "limit" => items_per_page }
    response = HTTParty.get(TAG_URL, :query => query)

    return total_results if response.code >= 500 || response["Tag"] == nil || response["Tag"]["Slideshow"] == nil
    
    #If the api returns multiple responses append them. If not just push the one hash. 
    total_results = total_results + response["Tag"]["Slideshow"] if response["Tag"]["Slideshow"].kind_of?(Array)
    total_results.push(response["Tag"]["Slideshow"]) if !response["Tag"]["Slideshow"].kind_of?(Array)
    total_results
    

    # CODE BELOW IS SETUP TO QUERY ALL SLIDES. HOWEVER THIS MAXED OUT MY API CALLS FOR THE DAY SO I DECIDED AGAINST IT.
    # limit = response["Tag"]["Count"]
    # byebug
    # while totalResults.length < limit.to_i do
    #   offset += items_per_page
    #   query["offset"] = offset
    #   response = HTTParty.get(TAG_URL, :query => query)
    #   break if response.code >= 500
    #   totalResults = totalResults + response["Tag"]["Slideshow"] if response["Tag"] != nil && response["Tag"]["Slideshow"] != nil
    # end
    # totalResults
  end

end