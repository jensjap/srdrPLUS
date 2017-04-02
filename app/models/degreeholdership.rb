class Degreeholdership < ApplicationRecord
  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  before_destroy :halp

  belongs_to :degree
  belongs_to :profile

  validates :profile_id, presence: true
  validates :degree_id, presence: true

  accepts_nested_attributes_for :degree, :allow_destroy => true, :reject_if => :all_blank
  accepts_nested_attributes_for :profile, :allow_destroy => true, :reject_if => :all_blank

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

  private

  def halp
  end
end

