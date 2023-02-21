# == Schema Information
#
# Table name: sd_key_questions_sd_picods
#
#  id                 :integer          not null, primary key
#  sd_key_question_id :integer
#  sd_picod_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  position           :integer          default(0)
#

class SdKeyQuestionsSdPicod < ApplicationRecord
  include SharedOrderableMethods

  belongs_to :sd_key_question, inverse_of: :sd_key_questions_sd_picods
  belongs_to :sd_picod, inverse_of: :sd_key_questions_sd_picods

  has_one :ordering, as: :orderable, dependent: :destroy
end
