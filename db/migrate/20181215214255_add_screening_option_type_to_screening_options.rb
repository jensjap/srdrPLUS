class AddScreeningOptionTypeToScreeningOptions < ActiveRecord::Migration[5.0]
  def change
    add_reference :screening_options, :screening_option_type, foreign_key: true
  end
end
