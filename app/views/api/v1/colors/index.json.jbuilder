json.colors do
  json.array!( @colors ) do |color|
    json.id color.id
    json.name sanitize(color.name)
    json.hex_code sanitize(color.hex_code)
  end
end