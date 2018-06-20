module SharedApprovableMethods
  extend ActiveSupport::Concern

  included do

    # Params:
    #   user [User]
    #
    # Returns:
    #   [Approval]
    #
    # Provide Approval.
    def approve_by(user)
      create_approval(user: user)
    end

    # Params:
    #
    # Returns:
    #   [Boolean]
    #
    # Provide Approval.
    def approved?
      approval.present?
    end
  end

  class_methods do
  end
end
