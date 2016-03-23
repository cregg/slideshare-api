class DocRankerJob < ActiveJob::Base
  queue_as :default

  def perform(company_url, company_name, hash)
    puts "Hash: " + hash
    company = Company.new(company_name, company_url)
    $redis[hash+"_status"] = "Looking For Documents..."
    ranked_docs = company.get_rel_docs
    $redis[hash + "_status"] = "Found " + company.array_of_relevant_docs.length.to_s + " Docs. Parsing Now..."
    rating_strategy = PDFReaderStrategy.new
    doc_rater = DocumentRater.new(company.key_words + company.get_split_names, company.array_of_relevant_docs.select{|doc| doc["Transcript"] != nil}, hash, rating_strategy)
    ranked_docs = doc_rater.update_and_return_rating_array
  end

end
