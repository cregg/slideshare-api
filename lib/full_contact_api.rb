class FullContactAPI

  API_KEY = ENV['FULL_CONTACT_API']
  FULL_CONTACT_URL = 'https://api.fullcontact.com/v2/company/lookup.json'
  @url
  @company_info

  def initialize url
    @url = url
  end

  def get_company_info
    # query = {:apiKey => API_KEY, :domain => @url, :keyPeople => 'true'}
    # For some reason HTTParty keeps sending back HTML when I pass more than one arg. 
    @company_info = HTTParty.get("https://api.fullcontact.com/v2/company/lookup.json?domain=#{@url}&apiKey=#{API_KEY}&keyPeople=true")
  end

  def get_key_people
    get_company_info if @company_info == nil
    return @company_info["organization"]["keyPeople"].map {|person| person["name"].downcase}
  end

  def get_keywords
    get_company_info if @company_info == nil
    return @company_info["organization"]["keywords"].map {|word| word.downcase}
  end

end