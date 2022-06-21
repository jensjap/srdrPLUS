# == Schema Information
#
# Table name: abstract_screening_results
#
#  id                     :bigint           not null, primary key
#  projects_users_role_id :bigint
#  abstract_screening_id  :bigint
#  citations_project_id   :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class AbstractScreeningResult < ApplicationRecord
  belongs_to :projects_user_role
  belongs_to :abstract_screening
  belongs_to :label
end
