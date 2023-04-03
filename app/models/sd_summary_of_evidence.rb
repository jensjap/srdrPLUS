# == Schema Information
#
# Table name: sd_summary_of_evidences
#
#  id                 :integer          not null, primary key
#  sd_meta_datum_id   :integer
#  sd_key_question_id :integer
#  name               :text(65535)
#  soe_type           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  pos                :integer          default(999999)
#

class SdSummaryOfEvidence < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :sd_meta_datum, inverse_of: :sd_summary_of_evidences, optional: true
  belongs_to :sd_key_question, inverse_of: :sd_summary_of_evidences, optional: true
  has_one :key_question, through: :sd_key_question
  has_many :sd_meta_data_figures, as: :sd_figurable

  accepts_nested_attributes_for :sd_meta_data_figures, allow_destroy: true
end
