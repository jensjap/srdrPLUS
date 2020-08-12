# Preview all emails at http://localhost:3000/rails/mailers/publishing
class PublishingPreview < ActionMailer::Preview
  def notify_admin_of_request
    PublishingMailer.notify_admin_of_request('Comparative Effectiveness of Management Strategies For Gastroesophageal Reflux Disease', 'SR360', 1)
  end

  def notify_publisher_of_request
    PublishingMailer.notify_publisher_of_request('test@example.com', 'Comparative Effectiveness of Management Strategies For Gastroesophageal Reflux Disease', 'SR360', 1)
  end

  def notify_publisher_of_approval
    PublishingMailer.notify_publisher_of_approval('test@example.com', 'Comparative Effectiveness of Management Strategies For Gastroesophageal Reflux Disease', 'SR360', 1)
  end
end
