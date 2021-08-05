json.colors do
  json.array!( @colors ) do |color|
    json.id color.id
    json.name CGI.escapeHTML(color.name)
    json.hex_code CGI.escapeHTML(color.hex_code)
  end
end