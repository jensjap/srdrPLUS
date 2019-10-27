# == Schema Information
#
# Table name: actions
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  action_type_id  :integer
#  actionable_type :string(255)
#  actionable_id   :integer
#  action_count    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Action < ApplicationRecord
  belongs_to :user
  belongs_to :action_type
  belongs_to :actionable, polymorphic: true
end
