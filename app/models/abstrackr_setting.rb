# == Schema Information
#
# Table name: abstrackr_settings
#
#  id              :integer          not null, primary key
#  profile_id      :integer
#  authors_visible :boolean          default(TRUE)
#  journal_visible :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class AbstrackrSetting < ApplicationRecord
    belongs_to :profile
end
