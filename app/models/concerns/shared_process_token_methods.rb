module SharedProcessTokenMethods
  extend ActiveSupport::Concern

  included do

    def process_token(token, resource_type)
      ActiveRecord::Base.transaction do
        token.gsub!(/<<<(.+?)>>>/) { resource_type.to_s.capitalize.constantize.create!(name: $1).id }
      end
    end

    # Similar to above...but here we have more complicated resource state so we receive it instead of
    # using constantize.
    def create_with_token(resource, token)
      ActiveRecord::Base.transaction do
        token.gsub!(/<<<(.+?)>>>/) { |new_id|
          resource.name = $1
          resource.save!
          new_id = resource.id
        }
      end
    end
  end

  class_methods do
  end

end


