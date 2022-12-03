# == Schema Information
#
# Table name: frequencies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Frequency < ApplicationRecord
  acts_as_paranoid
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    message_types.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  has_many :message_types, dependent: :destroy, inverse_of: :frequency
end
