# == Schema Information
#
# Table name: sd_journal_article_urls
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  position         :integer          default(999999)
#

class SdJournalArticleUrl < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :sd_meta_datum, inverse_of: :sd_journal_article_urls
end
