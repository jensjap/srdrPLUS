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
  default_scope { order(:pos, :id) }

  belongs_to :sf_cell
end
