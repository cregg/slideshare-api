class Company
  attr_reader :array_of_relevant_docs, :key_words

  @pronouns
  @top_words
  @docs
  @status
  @url
  @name
  @key_people_names
  @array_of_relevant_docs
  @key_words

  def initialize name, url
    @name = name
    @url = url
    @array_of_relevant_docs = []
    @key_people_names = []
    @key_words = []
  end

  # def get_tag_docs
  #   return @array_of_relevant_docs if !@array_of_relevant_docs.empty?
  #   init_pronouns_and_keywords 10
  #   pronouns_and_keywords = @pronouns + @top_words.reject { |word| @pronouns.include? word }
  #   pronouns_and_keywords.each do | pronoun |
  #     puts pronoun
  #     api = SlideshareAPI.new
  #     tag_docs = api.search_by_tag pronoun
  #     # if the description doens't contain the company name we're going to toss it.
  #     tag_docs = tag_docs.reject {|document| document["Description"] == nil}
  #     tag_docs_containing_company_name = tag_docs.reject {|document| document["Description"].downcase.include? @name.downcase}
  #     @array_of_relevant_docs = @array_of_relevant_docs + tag_docs_containing_company_name if tag_docs_containing_company_name != nil
  #   end
  #   @array_of_relevant_docs = @array_of_relevant_docs.uniq!
  #   $redis[@name] = @array_of_relevant_docs.to_json
  #   @array_of_relevant_docs
  # end

  def get_rel_docs
    return @array_of_relevant_docs if @array_of_relevant_docs.length > 0
    get_personelle_docs
    get_keyword_docs
    @array_of_relevant_docs.uniq! { |doc| doc["ID"]} 
  end

  def get_personelle_docs
    fc_api = FullContactAPI.new @url
    @key_people_names = fc_api.get_key_people
    @key_people_names.each do |person_name|
      slideshare_api = SlideshareAPI.new
      @array_of_relevant_docs += slideshare_api.search_by_query(person_name + " " + @name, 1)
      puts "Amount Of Docs: " + @array_of_relevant_docs.length.to_s
    end
  end

  def get_keyword_docs
    fc_api = FullContactAPI.new @url
    @key_words = fc_api.get_keywords
    @key_words.each do | key_word |
      slideshare_api = SlideshareAPI.new
      @array_of_relevant_docs += slideshare_api.search_by_query(key_word + " " + @name, 1)
      puts "Amount Of Docs: " + @array_of_relevant_docs.length.to_s
    end
    @key_words.push(@name) if !@key_words.include? @name
  end

  def get_split_names
    @key_people_names.map{|name| name.split(/W+/)}.flatten
  end

  def get_top_ten_words
    return JSON.parse($redis[@name + "_search_terms"]) if $redis[@name + "_search_terms"].length > 0
    company_meta_data = MetaInspector.new(@url)
    words = Hash.new(0)
    description = " " + company_meta_data.meta['description']
    company_meta_data.links.internal.each do | link |
      page_meta_data = MetaInspector.new(link)
      next if page_meta_data.meta["description"] == nil
      description += " " + page_meta_data.meta['description']
      next if page_meta_data.meta['keywords'] == nil
      description += " " + page_meta_data.meta['keywords']
    end
    tgr = EngTagger.new
    tagged_text = tgr.add_tags(description)
    ranked_words = tgr.get_words(tagged_text).sort_by { | word, count | count * -1 } 
    top_ten_words = ranked_words[0..9].map { | word_count_pair | word_count_pair[0].downcase }
    $redis[@name + "_search_terms"] = top_ten_words.to_json
    return top_ten_words
  end

  def init_pronouns_and_keywords top_number
    company_meta_data = MetaInspector.new(@url)
    pronouns = Hash.new(0)
    pronouns = pronouns.merge(get_pronouns_from_page company_meta_data.parsed)
    description = ""
    count = 0
    company_meta_data.links.internal.each do | link |
      count += 1
      break if count > 5
      next if link == nil 
      page_meta_data = MetaInspector.new(link)
      pronouns = pronouns.merge(get_pronouns_from_page(MetaInspector.new(link).parsed)) {|key, v1, v2| v1 + v2} if page_meta_data.parsed != nil
      description += " " + page_meta_data.meta['description'] if page_meta_data.meta["description"] != nil
      description += " " + page_meta_data.meta['keywords'] if page_meta_data.meta['keywords'] != nil
    end
    @top_words = init_top_words(top_number, description)
    pronouns.sort_by { | word, count | count * -1 } 
    pronouns = pronouns.map { | word_count_pair | word_count_pair[0].downcase }
    @pronouns = pronouns[0..top_number]
  end

  def get_pronouns_from_page noko_page
    noko_page.css('script').remove
    return {} if noko_page.at('body') == nil
    words_on_page = noko_page.at('body').inner_text
    tgr = EngTagger.new 
    tagged_text = tgr.add_tags(words_on_page)
    tgr.get_proper_nouns(tagged_text)
  end

  def init_top_words top_number, description
    tgr = EngTagger.new
    tagged_text = tgr.add_tags(description)
    ranked_words = tgr.get_words(tagged_text).sort_by { | word, count | count * -1 } 
    ranked_words[0..top_number].map { | word_count_pair | word_count_pair[0].downcase }    
  end

end