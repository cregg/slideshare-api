require 'json'

class DocumentRater
    
    @array_of_search_terms
    @array_of_docs
    @ranking_strategy
    @key

    def initialize(array_of_search_terms, array_of_docs, key, ranking_strategy)
        @array_of_search_terms = array_of_search_terms
        @array_of_docs = array_of_docs
        @key = key
        @ranking_strategy = ranking_strategy
    end

    def update_and_return_rating_array
        ranked_docs = $redis[@key] != nil ? JSON.parse($redis[@key]) : []
        tf_dash_idf = TFDashIDF.new(@array_of_search_terms, @array_of_docs.map{|doc| doc["Transcript"]})
        docs_parsed = 0
        @array_of_docs.each do |document|
            rating = 0
            document["found_terms"] = [];
            @array_of_search_terms.each do |term| 
                rating += tf_dash_idf.get_term_score(document["ID"], document["Transcript"].downcase, term)
                document["found_terms"].push(term) if document["Transcript"].include? term
            end
            document["rating"] = rating.nan? ? 0 : rating
            #Let's remove the transcript before storing. The transcript's can be pretty big. 
            document["Transcript"] = ""
            
            ranked_docs.push document
            ranked_docs = ranked_docs.sort_by {|hash| hash["rating"] * -1}
            docs_parsed += 1
            $redis[@key + "_status"] = "Parsing Doc: " + docs_parsed.to_s + "/" + @array_of_docs.length.to_s
            $redis[@key] = ranked_docs.to_json
        end
        ranked_docs
    end

    #Deprecated but holding on for fallback.
    def update_and_return_rating_array_dep
        ranked_docs = $redis[@key] != nil ? JSON.parse($redis[@key]) : []
        byebug
        tf_dash_idf = TFDashIDF.new(@array_of_search_terms, array_of_docs.map{|doc| doc["Description"]})
        @array_of_docs.each do | document |
            rating = @ranking_strategy.rank(document, @array_of_search_terms, @array_of_docs)
            document["rating"] = rating
            ranked_docs.push document
            ranked_docs = ranked_docs.sort_by {|hash| hash["rating"] * -1}
            $redis[@key] = ranked_docs.to_json
        end
        ranked_docs
    end

end