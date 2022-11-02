# == Schema Information
#
# Table name: sd_meta_data_figures
#
#  id                :bigint           not null, primary key
#  sd_figurable_id   :bigint
#  sd_figurable_type :string(255)
#  p_type            :string(255)
#  alt_text          :text(65535)
#

class SdMetaDataFigure < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_figurable, polymorphic: true

  def pictures=(attachables)
    attachables = Array(attachables).compact_blank

    if attachables.any?
      attachment_changes['pictures'] =
        ActiveStorage::Attached::Changes::CreateMany.new('pictures', self, pictures.blobs + attachables)
    end
  end
end
