# == Schema Information
#
# Table name: sd_analytic_frameworks
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdAnalyticFramework < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_meta_datum, inverse_of: :sd_analytic_frameworks
end
