module SharedMethods
  extend ActiveSupport::Concern

  included do
    # Params:
    #
    # Returns:
    #   Suggestion or nil
    #
    # This creates a Suggestion record for Suggestables during their after_create callback.
    def record_suggestor
      self.create_suggestion(user: User.current) if User.current
    end
  end

  class_methods do
    # Params:
    #   [String] Query string to search for Resource name
    #
    # Returns:
    #   [Array] An array of Resource found that match the query string
    def by_query(query)
      @resources = self.name.constantize.where('name like ?', "%#{ query }%").order(:name)
      return @resources.empty? ?
        [ OpenStruct.new(id: "<<<#{ query }>>>", name: "New: '#{ query }'", suggestion: false) ] : @resources
    end
  end

end

