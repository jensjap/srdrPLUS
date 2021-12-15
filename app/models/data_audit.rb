class DataAudit < ApplicationRecord
  DISTILLER_W_RESULTS_OPTIONS = ['Yes', 'No', 'N/A']
  SINGLE_MULTIPLE_W_CONSOLIDATION = [
    'Single',
    'Multiple Extraction w/ Consolidation',
    'Multiple Extraction w/o Consolidation'
  ]

  belongs_to :project
end
