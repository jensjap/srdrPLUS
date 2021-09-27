# == Schema Information
#
# Table name: journals
#
#  id               :integer          not null, primary key
#  citation_id      :integer
#  volume           :string(255)
#  issue            :string(255)
#  name             :string(1000)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  publication_date :string(255)
#

class Journal < ApplicationRecord
  belongs_to :citation, optional: true

  def get_publication_year
    get_year_through_date || get_year_through_date_time || ''
  end

  private

    def get_year_through_date
      self.publication_date.to_date.strftime('%Y')
    rescue
      nil
    end

    def get_year_through_date_time
      DateTime.strptime(self.publication_date, '%Y').strftime('%Y')
    rescue
      nil
    end
end
