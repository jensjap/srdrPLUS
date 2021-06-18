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
    begin
      datetime_object = self.publication_date.to_date
    rescue
      datetime_object = DateTime.strptime(self.publication_date, '%Y')
    end

    return datetime_object.blank? ? "" : datetime_object.strftime('%Y')
  end
end
