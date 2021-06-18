# == Schema Information
#
# Table name: sd_search_strategies
#
#  id                    :integer          not null, primary key
#  sd_meta_datum_id      :integer
#  sd_search_database_id :integer
#  date_of_search        :string(255)
#  search_limits         :text(16777215)
#  search_terms          :text(16777215)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class SdSearchStrategy < ApplicationRecord
  include SharedOrderableMethods
  include SharedProcessTokenMethods

  before_validation -> { set_ordering_scoped_by(:sd_meta_datum_id) }, on: :create

  # Made these associations optional so the autosave functions consistently -Birol
  #belongs_to :sd_meta_datum, inverse_of: :sd_search_strategies
  #belongs_to :sd_search_database, inverse_of: :sd_search_strategies

  belongs_to :sd_meta_datum, inverse_of: :sd_search_strategies, optional: true
  belongs_to :sd_search_database, inverse_of: :sd_search_strategies, optional: true

  has_one :ordering, as: :orderable, dependent: :destroy

  def sd_search_database_id=(token)
    save_resource_name_with_token(SdSearchDatabase.new, token)
    super
  end
end
