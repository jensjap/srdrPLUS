# == Schema Information
#
# Table name: sd_evidence_tables
#
#  id                :bigint           not null, primary key
#  name              :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sd_result_item_id :bigint
#

class SdEvidenceTable < ApplicationRecord
  include SharedOrderableMethods
  include SharedSdOutcomeableMethods
  belongs_to :sd_result_item, inverse_of: :sd_evidence_tables

  before_validation -> { set_ordering_scoped_by(:sd_result_item_id) }, on: :create

  has_one_attached :picture

  has_many :sd_outcomes, as: :sd_outcomeable
  has_one :ordering, as: :orderable, dependent: :destroy
end
