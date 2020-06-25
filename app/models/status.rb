# == Schema Information
#
# Table name: statuses
#
#  id   :bigint           not null, primary key
#  name :string(255)
#

class Status < ApplicationRecord
  has_many :statusings, inverse_of: :status
end
