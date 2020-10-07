class PublishingMailer < ApplicationMailer
  def notify_admin_of_request(title, name_of_pub_type, publishing_id, record_id)
    @title = title
    @name_of_pub_type = name_of_pub_type
    @record_id = record_id
    @publishing_id = publishing_id
    email = 'SRDR@AHRQ.hhs.gov'
    set_controller
    mail(to: email, subject: "Publishing requested")
  end

  def notify_publisher_of_request(email, title, name_of_pub_type, publishing_id, record_id)
    @title = title
    @name_of_pub_type = name_of_pub_type
    @record_id = record_id
    @publishing_id = publishing_id
    set_controller
    mail(to: email, subject: "Thank you for your submission")
  end

  def notify_publisher_of_approval(email, title, name_of_pub_type, publishing_id, record_id)
    @title = title
    @name_of_pub_type = name_of_pub_type
    @record_id = record_id
    @publishing_id = publishing_id
    set_controller
    mail(to: email, subject: "Your publication request has been approved")
  end

  private
    def set_controller
      case @name_of_pub_type
      when 'SR360'
        @controller = 'sd_meta_data'
      when 'Project'
        @controller = 'projects'
      end
    end
end
