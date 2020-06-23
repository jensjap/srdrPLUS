# == Schema Information
#
# Table name: sd_analysis_figures
#
#  id                :bigint           not null, primary key
#  sd_figurable_id   :bigint
#  sd_figurable_type :string(255)
#  p_type            :string(255)
#

class SdAnalysisFigure < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_figurable, polymorphic: true
end

