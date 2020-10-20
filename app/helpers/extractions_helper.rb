module ExtractionsHelper
  COLORS = %i(LightGreen Yellow LightBlue LavenderBlush Wheat LightGrey MintCream Turquoise Khaki SpringGreen).freeze

  def color(idx)
    if idx < 10
      COLORS[idx]
    else
      "rgb(#{(idx.hash % 100) + 155}, #{(idx.hash * 0.6 % 100) + 155}, #{(idx.hash * 0.2 % 100) + 155})"
    end
  end
end
