# == Schema Information
#
# Table name: abstract_screenings
#
#  id                      :bigint           not null, primary key
#  project_id              :bigint
#  abstract_screening_type :string(255)      default("perpetual"), not null
#  yes_tag_required        :boolean          default(FALSE), not null
#  no_tag_required         :boolean          default(FALSE), not null
#  maybe_tag_required      :boolean          default(FALSE), not null
#  yes_reason_required     :boolean          default(FALSE), not null
#  no_reason_required      :boolean          default(FALSE), not null
#  maybe_reason_required   :boolean          default(FALSE), not null
#  yes_note_required       :boolean          default(FALSE), not null
#  no_note_required        :boolean          default(FALSE), not null
#  maybe_note_required     :boolean          default(FALSE), not null
#  hide_author             :boolean          default(FALSE), not null
#  hide_journal            :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class AbstractScreening < ApplicationRecord
  ABSTRACTSCREENINGTYPES = { 'Perpetual': 'perpetual', 'Pilot': 'pilot' }.freeze

  validates_presence_of :abstract_screening_type

  belongs_to :project
  has_and_belongs_to_many :projects_users_roles
  has_and_belongs_to_many :citations_projects

  def add_citations_from_pool(no_of_citations)
    return if no_of_citations.nil?

    cps = project.citations_projects.where(screening_status: nil).limit(no_of_citations)
    citations_projects << cps
    cps.update_all(screening_status: 'AS')
  end

  def tag_options
    reqs = []
    reqs << 'Yes' if yes_tag_required
    reqs << 'No' if no_tag_required
    reqs << 'Maybe' if maybe_tag_required
    reqs
  end

  def reason_options
    reqs = []
    reqs << 'Yes' if yes_reason_required
    reqs << 'No' if no_reason_required
    reqs << 'Maybe' if maybe_reason_required
    reqs
  end

  def note_options
    reqs = []
    reqs << 'Yes' if yes_note_required
    reqs << 'No' if no_note_required
    reqs << 'Maybe' if maybe_note_required
    reqs
  end
end
