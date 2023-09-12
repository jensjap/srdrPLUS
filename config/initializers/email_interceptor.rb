class EmailInterceptor
  VALID_EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def self.delivering_email(message)
    to_emails = message.to

    if to_emails.respond_to?(:each)
      to_emails.each do |to_email|
        next if to_email.match?(VALID_EMAIL)

        # Invalid email address
        # Handle the error or take appropriate action
        raise "Invalid recipient email address: #{to_emails}"
      end

    else
      raise "Invalid recipient email address: #{to_emails}" unless to_emails.match?(VALID_EMAIL)

    end
  end
end

ActionMailer::Base.register_interceptor(EmailInterceptor)
