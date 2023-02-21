# == Schema Information
#
# Table name: sd_prisma_flows
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  position         :integer          default(0)
#

class SdPrismaFlow < ApplicationRecord
  include SharedOrderableMethods

  before_validation -> { set_ordering_scoped_by(:sd_meta_datum_id) }, on: :create

  belongs_to :sd_meta_datum, inverse_of: :sd_prisma_flows
  has_many :sd_meta_data_figures, as: :sd_figurable
  has_one :ordering, as: :orderable, dependent: :destroy

  accepts_nested_attributes_for :sd_meta_data_figures, allow_destroy: true
end
