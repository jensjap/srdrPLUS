class Citation < ApplicationRecord
  include SharedQueryableMethods
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail
  searchkick

  belongs_to :citation_type, optional: true

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
      resource = Author.new
      save_resource_name_with_token(resource, token)
    }
    super
  end

  def authors_attributes=(attributes)
    attributes.each do |key, attribute_collection|
      unless attribute_collection.has_key? 'id'
        Author.transaction do
          author = Author.find_or_create_by!(attribute_collection)
          authors << author unless authors.include? author
          attributes[key]['id'] = author.id.to_s
        end
      end
    end
    super
  end

  def keyword_ids=(tokens)
    tokens.map { |token|
      resource = Keyword.new
      save_resource_name_with_token(resource, token)
    }
    super
  end

  def keywords_attributes=(attributes)
    attributes.each do |key, attribute_collection|
      unless attribute_collection.has_key? 'id'
        Keyword.transaction do
          keyword = Keyword.find_or_create_by!(attribute_collection)
          keywords << keyword unless keywords.include? keyword
          attributes[key]['id'] = keyword.id.to_s
        end
      end
    end
    super
  end
end
