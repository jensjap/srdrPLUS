class Assignment < ApplicationRecord
  belongs_to :assignor, class_name: 'User', foreign_key: 'assignor_id'
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id'
end
