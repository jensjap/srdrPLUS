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
      # Approximate matches first.
      @resources = where('name like ?', "%#{ query }%")
      if @resources.blank?
        # If no approximate matches were found we can return an empty container for creation.
        return [ OpenStruct.new(id: "<<<#{ query }>>>", name: "New: '#{ query }'") ]

      else
        # If empty query was sent then we can return the full set of @resources found immediately.
        return @resources if query.blank?

        # Else, since approximate matches are found we check for exact matches.
        # We do this in case the user wants to create a resource that consists of a substring
        # of an existing resource.
        @exact_match = where('name=?', query)
        return @exact_match.blank? ?
          # !Warning: Using '+' actually converts the ActiveRecord to an array which means you can't use
          # AR methods afterwards.
          @resources + [ OpenStruct.new(id: "<<<#{ query }>>>", name: "New: '#{ query }'") ] : @resources
      end
    end

    # Params:
    #   [String] Field to search for Resource name
    #   [String] Query string to search for Resource name
    #
    # Returns:
    #   [Array] An array of the Resource found that matched the field and query string
    def by_name_description_and_query(query)
      where('name LIKE ? OR description LIKE ?', "%#{ query }%", "%#{ query }%")
    end
  end

end

