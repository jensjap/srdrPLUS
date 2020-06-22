# == Schema Information
#
# Table name: sd_outcomes
#
#  id                  :bigint           not null, primary key
#  name                :string(255)
#  sd_outcomeable_id   :bigint
#  sd_outcomeable_type :string(255)
#  deleted_at          :datetime
#

class SdOutcome < ApplicationRecord
  belongs_to :sd_outcomeable, polymorphic: true
end
