# == Schema Information
#
# Table name: ahoy_visits
#
#  id               :bigint           not null, primary key
#  visit_token      :string(255)
#  visitor_token    :string(255)
#  user_id          :bigint
#  ip               :string(255)
#  user_agent       :text(65535)
#  referrer         :text(65535)
#  referring_domain :string(255)
#  landing_page     :text(65535)
#  browser          :string(255)
#  os               :string(255)
#  device_type      :string(255)
#  country          :string(255)
#  region           :string(255)
#  city             :string(255)
#  latitude         :float(24)
#  longitude        :float(24)
#  utm_source       :string(255)
#  utm_medium       :string(255)
#  utm_term         :string(255)
#  utm_content      :string(255)
#  utm_campaign     :string(255)
#  app_version      :string(255)
#  os_version       :string(255)
#  platform         :string(255)
#  started_at       :datetime
#
class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user, optional: true
end
