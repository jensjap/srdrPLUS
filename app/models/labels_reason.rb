class LabelsReason < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  include SharedProcessTokenMethods

  belongs_to :label, inverse_of: :labels_reasons
  belongs_to :reason, inverse_of: :labels_reasons
  belongs_to :projects_users_role

  accepts_nested_attributes_for :reason

  def reason_id=(token)
    resource = Reason.new
    save_resource_name_with_token(resource, token)
    super
  end
end
