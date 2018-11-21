class Tagging < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

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
