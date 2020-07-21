class PublishingMailer < ApplicationMailer
  def notify_admin(name_of_pub_type, id)
    @name_of_pub_type = name_of_pub_type
    @id = id
    email = 'admin@srdrplus.ahrq.gov'
    mail(to: email, subject: "Publishing Requested")
  end

  def notify_publisher(email, name_of_pub_type, id)
    @name_of_pub_type = name_of_pub_type
    @id = id
    mail(to: email, subject: "Thank you for your submission")
  end
end
