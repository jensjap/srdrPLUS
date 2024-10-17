# == Schema Information
#
# Table name: abstract_screenings
#
#  id                      :bigint           not null, primary key
#  project_id              :bigint
#  abstract_screening_type :string(255)      default("single-perpetual"), not null
#  no_of_citations         :integer          default(0), not null
#  exclusive_users         :boolean          default(FALSE), not null
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
#  yes_form_required       :boolean          default(FALSE), not null
#  no_form_required        :boolean          default(FALSE), not null
#  maybe_form_required     :boolean          default(FALSE), not null
#
class AbstractScreening < ApplicationRecord
  include ScreeningModule

  validates_presence_of :abstract_screening_type
  #validate :double_screening_user_requirements, if: -> { requires_user_validation? }

  belongs_to :project

  has_many :abstract_screenings_users
  has_many :users, through: :abstract_screenings_users

  has_many :abstract_screenings_reasons
  has_many :reasons, through: :abstract_screenings_reasons
  has_many :abstract_screenings_tags
  has_many :tags, through: :abstract_screenings_tags

  has_many :abstract_screening_results, dependent: :destroy, inverse_of: :abstract_screening

  has_many :word_weights

  has_many :citations_projects
  has_many :abstract_screening_distributions, dependent: :destroy

  before_destroy :clear_citations_projects_abstract_screening_id

  def screening_type
    abstract_screening_type
  end

  def clear_citations_projects_abstract_screening_id
    project.citations_projects.where(abstract_screening_id: id).update_all(abstract_screening_id: nil)
  end

  private

  def requires_user_validation?
    ['double', 'expert-needed', 'only-expert-novice-mixed'].include?(abstract_screening_type)
  end

  def double_screening_user_requirements
    if exclusive_users
      if users.reject(&:blank?).size < 2
        errors.add(:users, 'Must select at least two users.')
      end
    else
      if project.users.size < 2
        errors.add(:base, 'Project must have at least two users.')
      end
    end
  end
end
