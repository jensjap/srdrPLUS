# == Schema Information
#
# Table name: notes
#
#  id                     :integer          not null, primary key
#  notable_type           :string(255)
#  notable_id             :integer
#  value                  :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  projects_users_role_id :integer
#  deleted_at             :datetime
#

class Note < ApplicationRecord
  acts_as_paranoid

  after_commit :reindex_citations_project

  belongs_to :projects_users_role
  belongs_to :notable, polymorphic: true

  delegate :project, to: :projects_users_role

  def reindex_citations_project
    notable.citations_project.reindex if notable.instance_of?(AbstractScreeningResult)
  end
end
