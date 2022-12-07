# == Schema Information
#
# Table name: tasks
#
#  id                        :integer          not null, primary key
#  task_type_id              :integer
#  project_id                :integer
#  num_assigned              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  required_inclusion_reason :boolean          default(FALSE)
#  required_exclusion_reason :boolean          default(FALSE)
#  required_maybe_reason     :boolean          default(FALSE)
#

class Task < ApplicationRecord
  belongs_to :task_type
  belongs_to :project # , touch: true

  has_many :assignments, dependent: :destroy
  has_many :projects_users_roles, through: :assignments

  accepts_nested_attributes_for :assignments

  def projects_users_role_ids=(pur_ids)
    pur_ids = pur_ids.reject(&:empty?)
    _assignment_arr = []
    pur_ids.each do |pur_id|
      _new_assignment = Assignment.find_or_create_by!(projects_users_role_id: pur_id, task: self)
      _assignment_arr << _new_assignment unless _assignment_arr.include? _new_assignment
    end
    self.assignments = _assignment_arr
  end
end
