# == Schema Information
#
# Table name: logs
#
#  id            :bigint           not null, primary key
#  loggable_type :string(255)      not null
#  loggable_id   :bigint           not null
#  description   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Log < ApplicationRecord
  belongs_to :loggable, polymorphic: true
end
