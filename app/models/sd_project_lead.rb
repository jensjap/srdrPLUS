# == Schema Information
#
# Table name: sd_project_leads
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdProjectLead < ApplicationRecord
end
