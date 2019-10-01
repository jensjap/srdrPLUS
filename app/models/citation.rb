class Citation < ApplicationRecord
  include SharedQueryableMethods
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail
  searchkick

  belongs_to :citation_type, optional: true

  has_one :journal, dependent: :destroy

  has_many :citations_projects, 
    dependent: :destroy, 
    inverse_of: :citation
  has_many :projects, 
      through: :citations_projects
  has_many :authors_citations,
    dependent: :destroy
  has_many :authors,
    through: :authors_citations
  has_many :labels, 
    through: :citations_projects, 
    dependent: :destroy
  has_and_belongs_to_many :keywords, 
    dependent: :destroy

  accepts_nested_attributes_for :authors_citations, 
    reject_if: :all_blank, 
    allow_destroy: true
  accepts_nested_attributes_for :keywords,
    reject_if: :all_blank, 
    allow_destroy: true
  accepts_nested_attributes_for :journal, 
    reject_if: :all_blank, 
    allow_destroy: true
  accepts_nested_attributes_for :labels, 
    reject_if: :all_blank, 
    allow_destroy: true

  def abstract_utf8
    abstract = self.abstract
    abstract.nil? ? '' : abstract.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
  end

  def author_ids=(tokens)
    tokens.map { |token|
      resource = Author.new
      save_resource_name_with_token(resource, token)
    }
    super
  end

  def authors_citations_attributes=(attributes)
    attributes.sort_by{|k,v| v[:ordering_attributes][:position]}.each do |key, attribute_collection|
      ActiveRecord::Base.transaction do
        unless attribute_collection.has_key? 'id'
          author = Author.find_or_create_by(name: attribute_collection[:author_attributes][:name])
          authors_citation = AuthorsCitation.find_or_create_by(citation: self, author: author)
          attributes[key]['id'] = authors_citation.id.to_s
        else
          authors_citation = AuthorsCitation.find attribute_collection[:id]
        end
        authors_citation.ordering.update(position: attribute_collection[:ordering_attributes][:position])
      end
    end
    super
  end

  def authors_attributes=(attributes)
    attributes.each do |key, attribute_collection|
      unless attribute_collection.has_key? 'id'
        Author.transaction do
          author = Author.find_or_create_by(attribute_collection)
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

  def handle
    string_handle = ""
#    string_handle += "Study Citation: #{ name } "
#    string_handle += "(PMID: #{ pmid.to_s })" if pmid.present?
    string_handle += (authors_citations.includes(:ordering).order('orderings.position asc').first&.author&.name || '')
    string_handle += ", "
    string_handle += journal.publication_date || ''
    string_handle += ", "
    string_handle += pmid || ''
    string_handle += "\n"
    string_handle += name

    return string_handle
  end
end
