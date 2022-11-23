# == Schema Information
#
# Table name: data_audits
#
#  id                                     :integer          not null, primary key
#  epc_source                             :boolean
#  epc_name                               :string(255)
#  non_epc_name                           :string(255)
#  capture_method                         :string(255)
#  distiller_w_results                    :string(255)
#  single_multiple_w_consolidation        :string(255)
#  notes                                  :text(65535)
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  pct_extractions_with_unstructured_data :string(255)
#  project_id                             :integer
#
class DataAudit < ApplicationRecord
  DISTILLER_W_RESULTS_OPTIONS = ['Yes', 'No', 'N/A']
  SINGLE_MULTIPLE_W_CONSOLIDATION = [
    'Single',
    'Multiple Extraction w/ Consolidation',
    'Multiple Extraction w/o Consolidation'
  ]

  belongs_to :project
end
