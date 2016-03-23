class TFDashIDF

  @array_search_terms
  @array_documents
  @total_word_count_hash
  @docs_containing_term_hash

  def initialize array_search_terms, array_documents
    @array_search_terms = array_search_terms
    @array_documents = array_documents
    @docs_containing_term_hash = Hash.new(nil)
  end

  def get_term_score document, term
    term_frequency(document, term) * inverse_doc_frequency(term)    
  end

private
  def term_frequency document, term
    tgr = EngTagger.new
    tagged_doc = tgr.add_tags document
    total_words = 0.0 + tgr.get_words(tagged_doc).values.sum
    doc_word_count_hash = tgr.get_words(document)
    puts "Word Count: " + doc_word_count_hash[term].to_s + " Total Words: " + total_words.to_s
    doc_word_count_hash[term] / total_words
  end

  def inverse_doc_frequency term
    puts "IDF: " + term
    docs_containing_term = @docs_containing_term_hash[term]
    return Math.log(@array_documents.length / (1.0 + docs_containing_term)) if docs_containing_term != nil
    docs_containing_term = 0;
    @array_documents.each{|document| docs_containing_term += 1 if document.include? term }
    @docs_containing_term_hash[term] = docs_containing_term
    puts "Totals Docs: " + @array_documents.length.to_s + " Docs Containing Term: " + docs_containing_term.to_s
    Math.log(@array_documents.length / (1.0 + docs_containing_term))
  end

end