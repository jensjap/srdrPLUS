# == Schema Information
#
# Table name: labels_reasons
#
#  id                     :integer          not null, primary key
#  label_id               :integer
#  reason_id              :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  projects_users_role_id :integer
#

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
