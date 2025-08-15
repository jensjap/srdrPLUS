module EmailHelper
  REGEX_PATTERN = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def valid_email(email)
    email.downcase if email =~ REGEX_PATTERN
  end

  def clean_email(email)
    # This regex removes unwanted characters (apostrophes, semicolons, pipes, etc.)
    email.gsub(/[';|<>`!#$%^&*()+=\[\]{}|\\\/?^~]/, '')
  end
end
