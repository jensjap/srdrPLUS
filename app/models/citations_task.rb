# == Schema Information
#
# Table name: citations_tasks
#
#  id          :integer          not null, primary key
#  citation_id :integer
#  task_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CitationsTask < ApplicationRecord
  belongs_to :citation
  belongs_to :task
end
