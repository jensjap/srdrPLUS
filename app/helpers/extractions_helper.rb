module ExtractionsHelper
  COLORS = %i(Aqua Yellow DarkBlue DarkGreen Indigo OrangeRed SpringGreen SlateGrey Brown Turquoise).freeze

  def color(number)
    COLORS[number % COLORS.count]
  end
end
