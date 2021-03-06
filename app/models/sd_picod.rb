# == Schema Information
#
# Table name: sd_picods
#
#  id                     :integer          not null, primary key
#  sd_meta_datum_id       :integer
#  name                   :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  population             :text(65535)
#  interventions          :text(65535)
#  comparators            :text(65535)
#  outcomes               :text(65535)
#  study_designs          :text(65535)
#  settings               :text(65535)
#  data_analysis_level_id :bigint
#  timing                 :text(65535)
#  other_elements         :text(65535)
#

class SdPicod < ApplicationRecord
  include SharedProcessTokenMethods
  include SharedOrderableMethods

  before_validation -> { set_ordering_scoped_by(:sd_meta_datum_id) }, on: :create

  has_many_attached :pictures

  belongs_to :data_analysis_level, inverse_of: :sd_meta_data, optional: true
  belongs_to :sd_meta_datum, inverse_of: :sd_picods

  has_many :sd_key_questions_sd_picods, inverse_of: :sd_picod, dependent: :destroy
  has_many :sd_key_questions, through: :sd_key_questions_sd_picods
  has_many :sd_picods_sd_picods_types, inverse_of: :sd_picod, dependent: :destroy
  has_many :sd_picods_types, through: :sd_picods_sd_picods_types

  has_one :ordering, as: :orderable, dependent: :destroy

  accepts_nested_attributes_for :sd_key_questions, allow_destroy: true
  accepts_nested_attributes_for :sd_picods_types, allow_destroy: true

  def sd_picods_type_ids=(tokens)
    tokens.map do |token|
      resource = SdPicodsType.new
      save_resource_name_with_token(resource, token)
    end
    super
  end
end
