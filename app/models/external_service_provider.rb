# == Schema Information
#
# Table name: external_service_providers
#
#  id          :bigint           not null, primary key
#  name        :string(255)
#  description :string(255)
#  url         :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ExternalServiceProvider < ApplicationRecord
end
