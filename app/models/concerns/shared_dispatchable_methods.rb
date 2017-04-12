module SharedDispatchableMethods
  extend ActiveSupport::Concern

  included do
    # Params:
    #   user [User]
    #
    # Returns:
    #   [Hash] or nil
    #
    # Return Hash with message_name and message_content if the message is stale.
    # A message is stale if the last time it was sent to this user is greater than
    # the interval set between start_at and end_at
    def dispatch_to(user)
      if User.current.dispatches.where(dispatchable_type: self.class).present?
        if User.current.dispatches.where(dispatchable_type: self.class).last.is_stale?
          return create_dispatch(user)
        end
      else
        return create_dispatch(user)
      end
      return false
    end

    def create_dispatch(user)
      dispatches.create(user: user)
      return { message_name: name, message_content: description }
    end
  end

  class_methods do
    # Params:
    #
    # Returns:
    #
    # Fetches a random Tip Of The Day message.
    def get_totd
      totd_messages = Message.where(message_type: MessageType.first)
      totd_messages.offset(rand(totd_messages.count)).first
    end
  end

end

