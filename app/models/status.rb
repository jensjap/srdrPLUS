# == Schema Information
#
# Table name: statuses
#
#  id   :bigint           not null, primary key
#  name :string(255)
#

class Status < ApplicationRecord
  DRAFT = 'Draft'.freeze
  COMPLETED = 'Completed'.freeze

  has_many :statusings, inverse_of: :status

  def self.DRAFT
    find_by(name: DRAFT)
  end

  def self.COMPLETED
    find_by(name: COMPLETED)
  end
end
