# == Schema Information
#
# Table name: sd_summary_of_evidences
#
#  id                 :integer          not null, primary key
#  sd_meta_datum_id   :integer
#  sd_key_question_id :integer
#  name               :text(16777215)
#  soe_type           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class SdSummaryOfEvidence < ApplicationRecord
  include SharedOrderableMethods

  before_validation -> { set_ordering_scoped_by(:sd_meta_datum_id) }, on: :create

  belongs_to :sd_meta_datum, inverse_of: :sd_summary_of_evidences, optional: true
  belongs_to :sd_key_question, inverse_of: :sd_summary_of_evidences, optional: true
  has_one :ordering, as: :orderable, dependent: :destroy
  has_one :key_question, through: :sd_key_question
  has_many :sd_meta_data_figures, as: :sd_figurable

  accepts_nested_attributes_for :sd_meta_data_figures, allow_destroy: true
end
