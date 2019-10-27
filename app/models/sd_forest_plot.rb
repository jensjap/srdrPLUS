# == Schema Information
#
# Table name: sd_forest_plots
#
#  id               :bigint(8)        not null, primary key
#  name             :text(65535)
#  sd_meta_datum_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdForestPlot < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_forest_plots
end
