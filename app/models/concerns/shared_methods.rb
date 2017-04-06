module SharedMethods
  extend ActiveSupport::Concern

  included do
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

