# == Schema Information
#
# Table name: sd_picods
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdPicod < ApplicationRecord
  include SharedProcessTokenMethods

  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_picods
  has_many :sd_key_questions_sd_picods, inverse_of: :sd_picod, dependent: :destroy
  has_many :sd_key_questions, through: :sd_key_questions_sd_picods
  has_many :sd_picods_sd_picods_types, inverse_of: :sd_picod, dependent: :destroy
  has_many :sd_picods_types, through: :sd_picods_sd_picods_types

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
