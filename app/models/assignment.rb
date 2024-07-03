# == Schema Information
#
# Table name: assignments
#
#  id              :bigint           not null, primary key
#  assignor_id     :integer
#  assignee_id     :integer
#  assignment_type :string(255)
#  assignment_id   :integer
#  assignor_status :string(255)
#  assignee_status :string(255)
#  link            :text(65535)
#  deadline        :datetime
#  archived        :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Assignment < ApplicationRecord
  has_many :logs, dependent: :destroy
  belongs_to :assignor, class_name: 'User', foreign_key: 'assignor_id'
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id'
  before_save :create_log_entries

  EXTRACTION = 'extraction'.freeze

  AWAITING_ASSIGNEE = 'awaiting_assignee'.freeze
  REJECTED = 'rejected'.freeze
  APPROVED = 'approved'.freeze

  PENDING = 'pending'.freeze
  COMPLETE = 'complete'.freeze

  def self.createdummy
    Assignment.create(assignor: User.first,
                      assignee: User.second,
                      assignment_type: EXTRACTION,
                      assignment_id: 334,
                      assignor_status: AWAITING_ASSIGNEE,
                      assignee_status: PENDING,
                      link: 'http://localhost:3000/extractions/334',
                      deadline: 2.days.from_now)
  end

  def handles
    {
      assignee: { handle: assignee.handle, id: assignee.id },
      assignor: { handle: assignor.handle, id: assignor.id }
    }
  end

  def formatted_deadline
    deadline.strftime('%F')
  end

  def create_log_entries
    logs.new(description: "Deadline set to #{deadline.strftime('%F')}") if deadline_changed?
    logs.new(description: "Assignee set to #{assignee.handle}") if assignee_changed?
    logs.new(description: "Assignor set to #{assignor.handle}") if assignor_changed?
    logs.new(description: "Assignee status set to #{assignee_status}") if assignee_status_changed?
    logs.new(description: "Assignor status set to #{assignor_status}") if assignor_status_changed?
    logs.new(description: "Archived status set to #{archived}") if archived_changed?
  end
end
