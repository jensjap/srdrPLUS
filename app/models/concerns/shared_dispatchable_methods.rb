module SharedDispatchableMethods
  extend ActiveSupport::Concern

  included do
    # Params:
    #   user [User]
    #
    # Returns:
    #   [Hash] or nil
    #
    # Return Dispatchable if it isn't stale.
    # Dispatchable is stale if the last time it was sent (Dispatch.last.created_at) is
    # greater than the cooldown set by Dispatchable.frequency
    def check_message
      current_time = Time.current
      current_user = User.current
      msg_time_range = start_at.to_i..end_at.to_i
      # Use start_at and end_at of Dispatchable to ensure we are in range to deliver.
      if msg_time_range === current_time.to_i
        if current_user.dispatches.where(dispatchable_type: self.class).present?
          # Also ensure that the last dispatch is older than dispatchable.frequency allows.
          if current_user.dispatches.where(dispatchable_type: self.class).last.is_stale?
            return create_dispatch(current_user)
          end
        else
          return create_dispatch(current_user)
        end
      end
    end

    def create_dispatch(resource)
      resource.dispatches.create(dispatchable: self)
      <<-message
        <dl>
          <dt>#{ name }</dt>
          <dd>#{ description }</dd>
        </dl>
      message
    end
  end

  class_methods do
    # Params:
    #
    # Returns:
    #   tip_of_the_day [Message]
    #
    # Fetches a random Tip Of The Day message.
    def get_totd
      totd_messages = Message.where(message_type: MessageType.first)
      totd_messages.offset(rand(totd_messages.count)).first
    end
  end

end

