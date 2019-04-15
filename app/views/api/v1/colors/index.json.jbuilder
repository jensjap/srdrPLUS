json.colors do
  json.array!( @colors ) do |color|
    json.id color.id
    json.name color.name
    json.hex_code color.hex_code
  end
end

