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
    #           a new Resource later. We also add a container object in case no exact match
    #           was found. This is for the case where user wishes to create a new resource but
    #           the resource's name is a substring of an existing one.
    #           Please note that you cannot chain AR methods after calling by_query.
    def by_query(query)
      # Try exact match first.
      exact_match = where("#{name.pluralize.underscore}.name=?", query)
      return exact_match unless exact_match.blank?

      # Try approximate matches using 'like'
      approximate_matches = where("#{name.pluralize.underscore}.name like ?", "%#{ query }%")
      return query.blank? ?
        approximate_matches : approximate_matches + [ OpenStruct.new(id: "<<<#{ query }>>>", name: "Other: '#{ query }'") ]
    end

    # Params:
    #   [String] Field to search for Resource name
    #   [String] Query string to search for Resource name
    #
    # Returns:
    #   [Array] An array of the Resource found that matched the field and query string
    def by_name_description_and_query(query)
      where("#{name.pluralize.underscore}.name LIKE ? OR #{name.pluralize.underscore}.description LIKE ?", "%#{ query }%", "%#{ query }%")
    end
  end
end
