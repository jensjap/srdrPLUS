# == Schema Information
#
# Table name: events
#
#  id          :bigint           not null, primary key
#  sent        :string(255)
#  action      :string(255)
#  resource    :string(255)
#  resource_id :integer
#  notes       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Event < ApplicationRecord
end
