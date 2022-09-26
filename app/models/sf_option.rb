class SfOption < ApplicationRecord
  belongs_to :sf_cell
  before_create :put_last

  private

  def put_last
    max_position = SfOption.where(sf_cell_id:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
