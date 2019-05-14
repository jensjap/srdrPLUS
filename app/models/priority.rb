# == Schema Information
#
# Table name: priorities
#
#  id                   :integer          not null, primary key
#  citations_project_id :integer
#  value                :integer
#  num_times_labeled    :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Priority < ApplicationRecord
  belongs_to :citations_project
end
