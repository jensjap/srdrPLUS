module SharedSuggestableMethods
  extend ActiveSupport::Concern

  included do

    # Params:
    #
    # Returns:
    #   Suggestion or nil
    #
    # This creates a Suggestion record for Suggestables during their after_create callback.
    def record_suggestor
      create_suggestion(user: User.current) if User.current
    end
  end

  class_methods do
  end

end

