# == Schema Information
#
# Table name: assignments
#
#  id              :bigint           not null, primary key
#  assignor_id     :integer
#  assignee_id     :integer
#  assignable_type :string(255)      not null
#  assignable_id   :bigint           not null
#  status          :string(255)
#  link            :text(65535)
#  deadline        :datetime
#  archived        :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Assignment < ApplicationRecord
  has_many :logs, dependent: :destroy
  has_many :assignments_messages, dependent: :destroy
  has_many :messages, through: :assignments_messages
  belongs_to :assignor, class_name: 'User', foreign_key: 'assignor_id'
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id'
  belongs_to :assignable, polymorphic: true
  before_save :create_log_entries

  EXTRACTION = 'extraction'.freeze

  AWAITING_WORK = 'awaiting_work'.freeze
  AWAITING_REVIEW = 'awaiting_review'.freeze
  WORK_APPROVED = 'work_approved'.freeze
  WORK_REJECTED = 'work_rejected'.freeze

  def handles
    {
      assignee: {
        handle: assignee.handle,
        id: assignee.id,
      },
      assignor: {
        handle: assignor.handle,
        id: assignor.id,
      },
    }
  end

  def name
    "Assignment# #{id}: #{assignable_type} #{assignable_id}"
  end

  def formatted_deadline
    deadline.strftime('%F')
  end

  def create_log_entries
    if deadline_changed?
      logs.new(description: "Deadline set to #{deadline.strftime('%F')}")
    end
    if assignee_changed?
      logs.new(description: "Assignee set to #{assignee.handle}")
    end
    if assignor_changed?
      logs.new(description: "Assignor set to #{assignor.handle}")
    end
    logs.new(description: "Status set to #{status}") if status_changed?
    if archived_changed?
      logs.new(description: "Archived status set to #{archived}")
    end
  end
end
