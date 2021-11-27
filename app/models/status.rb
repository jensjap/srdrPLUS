# == Schema Information
#
# Table name: statuses
#
#  id   :bigint           not null, primary key
#  name :string(255)
#

class Status < ApplicationRecord
  @@DRAFT     = 1
  @@COMPLETED = 2

  has_many :statusings, inverse_of: :status

  def self.DRAFT
    self.find(@@DRAFT)
  end

  def self.COMPLETED
    self.find(@@COMPLETED)
  end
end
