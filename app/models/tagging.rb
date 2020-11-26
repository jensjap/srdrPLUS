# == Schema Information
#
# Table name: taggings
#
#  id                     :integer          not null, primary key
#  tag_id                 :integer
#  taggable_type          :string(255)
#  taggable_id            :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  projects_users_role_id :integer
#  deleted_at             :datetime
#

class Tagging < ApplicationRecord
  acts_as_paranoid

  include SharedProcessTokenMethods

  belongs_to :projects_users_role
  belongs_to :tag
  belongs_to :taggable, polymorphic: true

  accepts_nested_attributes_for :tag

  def tag_id=(token)
    resource = Tag.new
    save_resource_name_with_token(resource, token)
    super
  end
end
