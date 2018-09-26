class Citation < ApplicationRecord
  include SharedQueryableMethods
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail
  searchkick

  belongs_to :citation_type

  has_one :journal, dependent: :destroy

  has_many :citations_projects, dependent: :destroy
  has_many :projects, through: :citations_projects
  has_and_belongs_to_many :authors, dependent: :destroy
  has_and_belongs_to_many :keywords, dependent: :destroy
  has_many :labels, through: :citations_projects

  accepts_nested_attributes_for :authors, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :keywords, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :journal, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :labels, reject_if: :all_blank, allow_destroy: true

  def author_ids=(tokens)
    tokens.map { |token|
      byebug
      resource = Author.new
      save_resource_name_with_token(resource, token)
    }
    super
  end

end
