# == Schema Information
#
# Table name: sd_analytic_frameworks
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  pos              :integer          default(999999)
#

class SdAnalyticFramework < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :sd_meta_datum, inverse_of: :sd_analytic_frameworks
  has_many :sd_meta_data_figures, as: :sd_figurable

  accepts_nested_attributes_for :sd_meta_data_figures, allow_destroy: true

  delegate :project, to: :sd_meta_datum
end
