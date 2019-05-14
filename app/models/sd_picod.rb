# == Schema Information
#
# Table name: sd_picods
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  p_type           :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdPicod < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_picods
  has_many :sd_key_questions_sd_picods, inverse_of: :sd_picod
  has_many :sd_key_questions, through: :sd_key_questions_sd_picods
  has_many :key_questions, through: :sd_key_questions
end
