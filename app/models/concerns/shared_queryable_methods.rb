module SharedQueryableMethods
  extend ActiveSupport::Concern

  included do
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
      @resources = name.constantize.where('name like ?', "%#{ query }%").order(:updated_at)
      return @resources.empty? ?
        [ OpenStruct.new(id: "<<<#{ query }>>>", name: "New: '#{ query }'", suggestion: false) ] : @resources
    end

    # Params:
    #   [String] Field to search for Resource name
    #   [String] Query string to search for Resource name
    #
    # Returns:
    #   [Array] An array of the Resource found that matched the field and query string
    def by_name_description_and_query(query)
      name.constantize.where('name LIKE ? OR description LIKE ?', "%#{ query }%", "%#{ query }%").order(:updated_at)
    end
  end

end

