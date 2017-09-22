class Citation < ApplicationRecord
  belongs_to :citation_type
  has_many :citations_projects
  has_many :projects, through: :citations_projects
  has_many :authors
  has_many :keywords 
  has_one :journal
end
