class AddComparableElementRefToComparates < ActiveRecord::Migration[5.0]
  def change
    add_reference :comparates, :comparable_element, foreign_key: true
  end
end
