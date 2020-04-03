module SharedSdOutcomeableMethods
  extend ActiveSupport::Concern
  
  included do
    def sd_outcome_names
      # Even though it is inefficient to repeat the query every time this method is called, not doing so causes weird bugs. -Birol
      SdOutcome.where(sd_outcomeable_id: self.id, sd_outcomeable_type: self.class.name).map{ |sd_outcome| sd_outcome.name }
    end

    def sd_outcome_names=(tokens)
      tokens = (tokens - [""]).uniq
      existing_outcome_names = self.sd_outcome_names
      (tokens - existing_outcome_names).each do |token|
        new_sd_outcome = self.sd_outcomes.find_or_create_by( name: token )
        new_sd_outcome.save!
      end
      self.sd_outcomes.where( name: (existing_outcome_names - tokens) ).delete_all
    end
  end

  class_methods do
  end
end
