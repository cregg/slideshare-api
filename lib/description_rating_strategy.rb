class DescriptionRatingStrategy

    def initialize
    end

    def rank document, array_of_search_terms, array_of_docs
        rating = 0.0;
        description = document["Description"]
        return 0 if description == nil
        array_of_search_terms.each do | term |
            rating += 1 if description.include? term
        end
        rating / array_of_search_terms.length
    end

end