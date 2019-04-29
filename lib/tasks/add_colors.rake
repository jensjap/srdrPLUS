task add_colors: [:environment] do
  # Colors
  color_arr = [
                   { hex_code:'#AE2724', name: 'Dark Red' },
                   { hex_code:'#EC3524', name: 'Red' },
                   { hex_code:'#F7C342', name: 'Orange' },
                   { hex_code:'#F6F05D', name: 'Yellow' },
                   { hex_code:'#9FCE63', name: 'Light Green' },
                   { hex_code:'#4DAE5A', name: 'Green' },
                   { hex_code:'#51ABE0', name: 'Light Blue' },
                   { hex_code:'#2A6EB5', name: 'Blue' },
                   { hex_code:'#1E2759', name: 'Dark Blue' },
                   { hex_code:'#673996', name: 'Purple' }
               ]

  color_arr.each do |color_hash|
    color = Color.find_by(color_hash)
    if color.present?
      puts "#{color_hash[:name]} already present, skipping... "
    else
      Color.create!(color_hash)
      puts "#{color_hash[:name]} missing, creating... "
    end
  end
end
