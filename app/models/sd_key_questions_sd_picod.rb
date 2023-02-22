# == Schema Information
#
# Table name: sd_key_questions_sd_picods
#
#  id                 :integer          not null, primary key
#  sd_key_question_id :integer
#  sd_picod_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  position           :integer          default(999999)
#

class SdKeyQuestionsSdPicod < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :sd_key_question, inverse_of: :sd_key_questions_sd_picods
  belongs_to :sd_picod, inverse_of: :sd_key_questions_sd_picods
end
