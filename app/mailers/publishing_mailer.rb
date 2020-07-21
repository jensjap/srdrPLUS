class PublishingMailer < ApplicationMailer
  def notify_admin_of_request(title, name_of_pub_type, id)
    @title = title
    @name_of_pub_type = name_of_pub_type
    @id = id
    email = 'bryant_smith@brown.edu'
    mail(to: email, subject: "Publishing requested")
  end

  def notify_publisher_of_request(email, title, name_of_pub_type, id)
    @title = title
    @name_of_pub_type = name_of_pub_type
    @id = id
    mail(to: email, subject: "Thank you for your submission")
  end

  def notify_publisher_of_approval(email, title, name_of_pub_type, id)
    @title = title
    @name_of_pub_type = name_of_pub_type
    @id = id
    mail(to: email, subject: "Your publication request has been approved")
  end
end
