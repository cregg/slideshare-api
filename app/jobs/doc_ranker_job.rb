class DocRankerJob < ActiveJob::Base
  queue_as :default

  #Use Redis to store status updates + docs being used. 
  def perform(company_url, company_name, hash)
    begin
      puts "Hash: " + hash
      company = Company.new(company_name, company_url, hash)
      $redis[hash+"_status"] = "Looking For Documents..."
      ranked_docs = company.get_rel_docs
      $redis[hash + "_status"] = "Found " + company.array_of_relevant_docs.length.to_s + " somewhat relevant Docs. Ranking Now..."
      rating_strategy = PDFReaderStrategy.new
      search_terms = company.key_words + company.key_people_names
      doc_rater = DocumentRater.new(search_terms, company.array_of_relevant_docs, hash, rating_strategy)
      ranked_docs = doc_rater.update_and_return_rating_array
    rescue => error
      error.backtrace
      puts 'Some Weird Error happened'
      doc_count = $redis[hash] == nil || $redis[hash] == "" ? 0 : JSON.parse($redis[hash]).length
      $redis[hash + "_status"] = "Encountered an Error: Parsed " + doc_count.to_s + " docs."
    end
  end

end
