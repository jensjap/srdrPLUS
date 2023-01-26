# == Schema Information
#
# Table name: sd_meta_data_figures
#
#  id                             :bigint           not null, primary key
#  sd_figurable_id                :bigint
#  sd_figurable_type              :string(255)
#  p_type                         :string(255)
#  alt_text                       :text(65535)
#  outcome_type                   :string(255)      default("Categorical")
#  intervention_name              :string(255)
#  comparator_name                :string(255)
#  effect_size_measure_name       :string(255)
#  overall_effect_size            :string(255)
#  overall_95_ci_low              :string(255)
#  overall_95_ci_high             :string(255)
#  overall_i_squared              :string(255)
#  other_heterogeneity_statistics :text(65535)
#

class SdMetaDataFigure < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_figurable, polymorphic: true

  after_create :follow_older_sibiling_values

  def pictures=(attachables)
    attachables = Array(attachables).compact_blank

    if attachables.any?
      attachment_changes['pictures'] =
        ActiveStorage::Attached::Changes::CreateMany.new('pictures', self, pictures.blobs + attachables)
    end
  end

  private

  def follow_older_sibiling_values
    return unless sd_figurable.instance_of?(SdPairwiseMetaAnalyticResult)

    older_sibling = SdMetaDataFigure.where(sd_figurable:).where('id < ?',
                                                                id).order(id: :desc).limit(1).first
    return unless older_sibling.present?

    self.outcome_type = older_sibling.outcome_type
    self.intervention_name = older_sibling.intervention_name
    self.comparator_name = older_sibling.comparator_name
    self.effect_size_measure_name = older_sibling.effect_size_measure_name
    save
  end
end
