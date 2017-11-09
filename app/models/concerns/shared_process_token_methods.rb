module SharedProcessTokenMethods
  extend ActiveSupport::Concern

  included do

    def process_token(token, resource_type)
      ActiveRecord::Base.transaction do
        token.gsub!(/<<<(.+?)>>>/) { resource_type.to_s.capitalize.constantize.create!(name: $1).id }
      end
    end

    def save_resource_name_with_token(resource, token)
      ActiveRecord::Base.transaction do
        token.gsub!(/<<<(.+?)>>>/) { |new_id|
          resource.update(name: $1)
          #resource.name = $1
          #resource.save!
          new_id = resource.id
        }
      end
    end
  end

  class_methods do
  end

end


