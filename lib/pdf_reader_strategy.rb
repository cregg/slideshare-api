require 'open-uri'

class PDFReaderStrategy

  def initialize
  end

  def rank document, array_of_search_terms, array_of_docs
    rating = 0.0
    return rating if document["Download"].to_i != 1
    puts "Downloading " + document["Title"] + ":" + document["DownloadUrl"]
    io = open(document["DownloadUrl"])
    puts "Downloaded " + document["Title"]
    reader = PDF::Reader.new(io)
    text = ""
    reader.pages.each do |page|
      puts page.text
      text += page.text + " "
    end
    text_to_words = text.split(/\W+/)
    text_to_words.each do | term |
        puts term
        rating += 1 if array_of_search_terms.include? term
    end
    return rating / array_of_search_terms.length
  rescue OpenURI::HTTPError => error
    puts error.to_s
    rating
  end
    
end