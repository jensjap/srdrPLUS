# == Schema Information
#
# Table name: sf_options
#
#  id            :bigint           not null, primary key
#  sf_cell_id    :bigint
#  name          :string(255)      not null
#  with_followup :boolean          default(FALSE), not null
#  position      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class SfOption < ApplicationRecord
  belongs_to :sf_cell
  before_create :put_last

  private

  def put_last
    max_position = SfOption.where(sf_cell_id:).maximum(:position)
    self.position = max_position ? max_position + 1 : 1
  end
end
