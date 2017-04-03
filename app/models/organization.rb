class Organization < ApplicationRecord
  acts_as_paranoid

  has_many :profiles, dependent: :destroy, inverse_of: :profile

  def self.add_suggested_resource(suggested_resource)
    if suggested_resource.is_a? String
      return self.find_or_initialize_by(name: suggested_resource)
    else
      raise 'Organization::add_suggested_resource - Did not get a String'
    end
  end
end

