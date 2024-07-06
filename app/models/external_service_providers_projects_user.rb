# == Schema Information
#
# Table name: external_service_providers_projects_users
#
#  id                           :bigint           not null, primary key
#  external_service_provider_id :bigint           not null
#  project_id                   :integer          not null
#  user_id                      :integer          not null
#  api_token                    :string(255)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class ExternalServiceProvidersProjectsUser < ApplicationRecord
  belongs_to :external_service_provider
  belongs_to :project
  belongs_to :user

  validates :api_token, presence: true
end
