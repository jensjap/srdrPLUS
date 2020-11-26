# == Schema Information
#
# Table name: assignments
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  task_id                :integer
#  done_so_far            :integer
#  date_assigned          :datetime
#  date_due               :datetime
#  done                   :integer
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  projects_users_role_id :integer
#  mutable                :boolean          default(TRUE)
#

class Assignment < ApplicationRecord
  acts_as_paranoid

  belongs_to :projects_users_role, optional: true
  belongs_to :task, optional: true

  has_one :project, through: :task

  delegate :user, to: :projects_users_role
  delegate :projects_user, to: :projects_users_role
end
