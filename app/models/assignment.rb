class Assignment < ApplicationRecord
  has_many :logs
  belongs_to :assignor, class_name: 'User', foreign_key: 'assignor_id'
  belongs_to :assignee, class_name: 'User', foreign_key: 'assignee_id'
  # t.references :assignor, index: true, type: :int, foreign_key: { to_table: :users }
  # t.references :assignee, index: true, type: :int, foreign_key: { to_table: :users }
  # t.string :assignment_type, index: true
  # t.integer :assignment_id, index: true
  # t.string :assignor_status
  # t.string :assignee_status
  # t.text :link
  # t.datetime :deadline
  EXTRACTION = 'extraction'.freeze
  PENDING = 'pending'.freeze
  APPROVED = 'approved'.freeze
  REJECTED = 'rejected'.freeze
  IN_PROGRESS = 'in_progress'.freeze
  COMPLETE = 'complete'.freeze
  after_create :create_log

  def self.createdummy
    Assignment.create(assignor: User.first,
                      assignee: User.second,
                      assignment_type: EXTRACTION,
                      assignment_id: 334,
                      assignor_status: PENDING,
                      assignee_status: IN_PROGRESS,
                      link: 'http://localhost:3000/extractions/334',
                      deadline: 2.days.from_now)
  end

  def create_log
    logs.create(description: "User #{assignor.id} assigned User #{assignee.id} #{assignment_type} #{assignment_id} with deadline #{deadline}").save
  end
end
