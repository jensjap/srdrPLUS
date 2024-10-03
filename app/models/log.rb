# == Schema Information
#
# Table name: logs
#
#  id            :bigint           not null, primary key
#  loggable_type :string(255)      not null
#  loggable_id   :bigint           not null
#  description   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Log < ApplicationRecord
  belongs_to :loggable, polymorphic: true
  belongs_to :user, optional: true

  # Below doesn't work with Log.create!(extraction: ...)
  has_one :self_ref, class_name: 'Log', foreign_key: :id
  has_one :extraction, through: :self_ref, source: :loggable, source_type: 'Extraction'
  # See note above

  attribute :handle, type: :string
  attribute :citation_name, type: :string

  def handle
    user&.handle
  end

  def citation_name
    return '' unless loggable_type == 'Extraction'

    extraction.citations_project.citation.name
  end
end
