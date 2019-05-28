namespace :color_choice_tasks do
  desc "Adds ColorChoice seed data"
  task AddSeedNames: :environment do
    [
      ['white',   '#FFFFFF', 'rgb(255, 255, 255)'],
      ['silver',  '#C0C0C0', 'rgb(192, 192, 192)'],
      ['gray',    '#808080', 'rgb(128, 128, 128)'],
      ['black',   '#000000', 'rgb(0, 0, 0)'],
      ['red',     '#FF0000', 'rgb(255, 0, 0)'],
      ['maroon',  '#800000', 'rgb(128, 0, 0)'],
      ['yellow',  '#FFFF00', 'rgb(255, 255, 0)'],
      ['olive',   '#808000', 'rgb(128, 128, 0)'],
      ['lime',    '#00FF00', 'rgb(0, 255, 0)'],
      ['green',   '#008000', 'rgb(0, 128, 0)'],
      ['aqua',    '#00FFFF', 'rgb(0, 255, 255)'],
      ['teal',    '#008080', 'rgb(0, 128, 128)'],
      ['blue',    '#0000FF', 'rgb(0, 0, 255)'],
      ['navy',    '#000080', 'rgb(0, 0, 128)'],
      ['fuchsia', '#FF00FF', 'rgb(255, 0, 255))'],
      ['purple',  '#800080', 'rgb(128, 0, 128))']
    ].each do |color|
      ColorChoice.find_or_create_by(
        name: color[0],
        hex_code: color[1],
        rgb_code: color[2]
      )
    end
  end

end
