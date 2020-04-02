module SharedSdOutcomeableMethods
  extend ActiveSupport::Concern
  
  included do
    def sd_outcome_names
      self.sd_outcomes.map{ |sd_outcome| sd_outcome.name }
    end

    def sd_outcome_names=(tokens)
      tokens = tokens - [""]
      existing_outcome_names = self.sd_outcome_names
      (tokens - existing_outcome_names).each do |token|
        new_sd_outcome = self.sd_outcomes.find_or_create_by( name: token )
        new_sd_outcome.save!
      end
      self.sd_outcomes.where( name: (existing_outcome_names - tokens) ).destroy_all
    end
  end

  class_methods do
  end
end
