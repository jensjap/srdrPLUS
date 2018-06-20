module SharedProcessTokenMethods
  extend ActiveSupport::Concern

  included do

#    def process_token(token, resource_type)
#      ActiveRecord::Base.transaction do
#        token.gsub!(/<<<(.+?)>>>/) { resource_type.to_s.capitalize.constantize.create!(name: $1).id }
#      end
#    end

    # Take the token string and substitute /<<<(.+?)>>>/ with the id of the resource.
    #
    # Returns the token string with the corresponding IDs.
    def save_resource_name_with_token(resource, token)
      ActiveRecord::Base.transaction do
        token.gsub!(/<<<(.+?)>>>/) { |new_id|
          resource.update(name: $1)
          new_id = resource.id
        }
      end
    end
  end

  class_methods do
  end
end
