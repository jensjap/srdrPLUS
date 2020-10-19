module ExtractionsHelper
  COLORS = %i(Aqua Brown DarkBlue DarkGreen Indigo OrangeRed SpringGreen SlateGrey Yellow Turquoise).freeze

  def color(number)
    COLORS[number % COLORS.count]
  end
end
