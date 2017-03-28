class Degreeholdership < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :profile
  belongs_to :degree

  validates :profile_id, presence: true
  validates :degree_id, presence: true

  def paranoia_restore_attributes
    {
      deleted_at: nil,
      active: true
    }
  end

  def paranoia_destroy_attributes
    {
      deleted_at: current_time_from_proper_timezone,
      active: nil
    }
  end
end
