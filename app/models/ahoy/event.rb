# == Schema Information
#
# Table name: ahoy_events
#
#  id         :bigint           not null, primary key
#  visit_id   :bigint
#  user_id    :bigint
#  name       :string(255)
#  properties :text(4294967295)
#  time       :datetime
#
class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true
end
