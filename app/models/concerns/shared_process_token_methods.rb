module SharedProcessTokenMethods
  extend ActiveSupport::Concern

  included do

    def process_token(token, resource_type)
      ActiveRecord::Base.transaction do
        token.gsub!(/<<<(.+?)>>>/) { resource_type.to_s.capitalize.constantize.create!(name: $1).id }
      end
    end
  end

  class_methods do
  end

end


