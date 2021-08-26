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
    def save_resource_name_with_token(resource, token, originating_record = nil, joint_class = nil)
      ActiveRecord::Base.transaction do
        token.gsub!(/<<<(.+?)>>>/) { |new_id|
          resource.update(name: $1.gsub("<", "").gsub(">", ""))
          new_id = resource.id

          joint_record = nil
          if originating_record && originating_record.save!
            joint_record = joint_class.find_or_create_by(
              "#{resource.class.table_name.singularize}_id": new_id,
              "#{originating_record.class.table_name.singularize}_id": originating_record.id,
            )
          end
          joint_record ? joint_record.id : new_id
        }
      end
    end
  end

  class_methods do
  end
end
