# == Schema Information
#
# Table name: extraction_checksums
#
#  id            :bigint           not null, primary key
#  extraction_id :bigint
#  hexdigest     :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  is_stale      :boolean
#

class ExtractionChecksum < ApplicationRecord
  scope :not_disqualified,
        lambda {
          where.not(
            extraction_id: CitationsProject.where(
              screening_status: CitationsProject::REJECTED
            ).select(:extraction_id)
          )
        }

  belongs_to :extraction

  after_create :update_hexdigest

  def update_hexdigest
    return unless extraction.present?

    e_json = ApplicationController.new.view_context.render(
      partial: 'extractions/extraction_for_comparison_tool',
      locals: { extraction: },
      formats: [:json],
      handlers: [:jbuilder]
    )
    update(hexdigest: Digest::MD5.hexdigest(e_json), is_stale: false)
  end
end
