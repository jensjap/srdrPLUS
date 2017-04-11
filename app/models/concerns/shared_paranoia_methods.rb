module SharedParanoiaMethods
  extend ActiveSupport::Concern

  included do

    # Used by Paranoia gem.
    def paranoia_restore_attributes
      {
        deleted_at: nil,
        active: true
      }
    end

    def paranoia_destroy_attributes
      {
        deleted_at: current_time_from_proper_timezone,
        active: nil
      }
    end
  end

  class_methods do
  end

end
