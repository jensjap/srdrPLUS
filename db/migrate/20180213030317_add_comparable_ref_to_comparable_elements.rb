class AddComparableRefToComparableElements < ActiveRecord::Migration[5.0]
  def change
    add_reference :comparable_elements, :comparable, polymorphic: true, index: true
  end
end
