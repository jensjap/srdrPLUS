class OnlineStatusChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user.id
    current_user.update(online_status: 'online')
  end

  def unsubscribed
    current_user.update(online_status: 'offline')
  end
end
