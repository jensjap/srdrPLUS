# Preview all emails at http://localhost:3000/rails/mailers/publishing
class PublishingPreview < ActionMailer::Preview
  def notify_admin
    PublishingMailer.notify_admin('SR360', 1)
  end

  def notify_publisher
    PublishingMailer.notify_publisher('test@example.com', 'SR360', 1)
  end
end
