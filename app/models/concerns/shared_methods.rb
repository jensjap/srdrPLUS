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
    #   [Array] An array of Resource found that match the query string, if none was found
    #           it returns an array with a single object element. This will assist in creating
    #           a new Resource later.
    def by_query(query)
      @resources = self.name.constantize.where('name like ?', "%#{ query }%").order(:name)
      return @resources.empty? ?
        [ OpenStruct.new(id: "<<<#{ query }>>>", name: "New: '#{ query }'", suggestion: false) ] : @resources
    end

    # Params:
    #   [String] Field to search for Resource name
    #   [String] Query string to search for Resource name
    #
    # Returns:
    #   [Array] An array of the Resource found that matched the field and query string
    def by_field_and_query(field, query)
      self.name.constantize.where('name like ?', "%#{ query }%").order(:name)
    end
  end

end

