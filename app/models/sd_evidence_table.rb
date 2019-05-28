class SdEvidenceTable < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_evidence_tables
end
