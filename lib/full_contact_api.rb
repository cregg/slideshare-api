class FullContactAPI

  API_KEY = ENV['FULL_CONTACT_API']
  FULL_CONTACT_URL = 'https://api.fullcontact.com/v2/company/lookup.json'
  @url
  @company_info
  @key_people
  @keywords

  def initialize url
    @url = url
    @key_people = []
    @keywords = []
  end

  def get_company_info
    # query = {:apiKey => API_KEY, :domain => @url, :keyPeople => 'true'}
    # For some reason HTTParty keeps sending back HTML when I pass more than one arg. 
    @company_info = HTTParty.get("https://api.fullcontact.com/v2/company/lookup.json?domain=#{@url}&apiKey=#{API_KEY}&keyPeople=true")
  end

  def get_key_people
    get_company_info if @company_info == nil
    @key_people = @company_info["organization"]["keyPeople"].map {|person| person["name"].downcase} if @company_info["organization"]["keyPeople"] != nil
    return @key_people
  end

  def get_keywords
    get_company_info if @company_info == nil
    @keywords = @company_info["organization"]["keywords"].map {|word| word.downcase} if @company_info["organization"]["keywords"] 
    return @keywords
  end

end