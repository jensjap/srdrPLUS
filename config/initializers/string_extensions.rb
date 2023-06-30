# Extending String class to add some convenience methods.
class String
  def to_bool
    return true if self == 'true'
    return false if self == 'false'

    raise ArgumentError, "Invalid value for boolean conversion: #{self}"
  end

  def strip_control_characters
    chars.each_with_object("") do |char, str|
      str << char unless char.ascii_only? and (char.ord < 32 or char.ord == 127)
    end
  end

  def strip_control_and_extended_characters
    chars.each_with_object("") do |char, str|
      str << char if char.ascii_only? and char.ord.between?(32,126)
    end
  end

  def get_url
    uri = URI.parse(self)
    if %w( http https ).include?(uri.scheme)
      return uri.to_s
    else
      return false
    end
    rescue URI::BadURIError
      false
    rescue URI::InvalidURIError
      false
  end
end
