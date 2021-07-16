module EmailHelper
  REGEX_PATTERN = /^(.+)@(.+)$/

  def valid_email(email)
    email.downcase if email =~REGEX_PATTERN
  end
end
