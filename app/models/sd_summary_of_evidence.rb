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
#

class SdSummaryOfEvidence < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_summary_of_evidences
  belongs_to :sd_key_question, inverse_of: :sd_summary_of_evidences
end
