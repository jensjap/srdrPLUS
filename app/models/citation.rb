# == Schema Information
#
# Table name: citations
#
#  id                :integer          not null, primary key
#  citation_type_id  :integer
#  name              :string(500)
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  refman            :string(255)
#  pmid              :string(255)
#  abstract          :binary(65535)
#  page_number_start :integer
#  page_number_end   :integer
#

class Citation < ApplicationRecord
  include SharedQueryableMethods
  include SharedProcessTokenMethods

  acts_as_paranoid
  searchkick

  belongs_to :citation_type, optional: true

  has_one :journal, dependent: :destroy

  has_many :citations_projects, dependent: :destroy, inverse_of: :citation
  has_many :projects, through: :citations_projects
  has_many :authors_citations, dependent: :destroy
  has_many :authors, through: :authors_citations
  has_many :labels, through: :citations_projects, dependent: :destroy
  has_and_belongs_to_many :keywords, dependent: :destroy

  accepts_nested_attributes_for :authors_citations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :keywords, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :journal, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :labels, reject_if: :all_blank, allow_destroy: true

  # Redundant?
  def abstract_utf8
    abstract = self.read_attribute(:abstract)
    abstract.nil? ? '' : abstract.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
  end

  # Without this Searchkick cannot create indices
  def abstract
    (self.read_attribute(:abstract) || '').force_encoding('UTF-8')
  end

  def author_ids=(tokens)
    tokens.map do |token|
      resource = Author.new
      save_resource_name_with_token(resource, token)
    end
    super
  end

#  def authors_citations_attributes=(attributes)
#    attributes.sort_by{|k,v| v[:ordering_attributes][:position]}.each do |key, attribute_collection|
#      ActiveRecord::Base.transaction do
#        unless attribute_collection.has_key? 'id'
#          author = Author.find_or_create_by(name: attribute_collection[:author_attributes][:name])
#          authors_citation = AuthorsCitation.find_or_create_by(citation: self, author: author)
#          attributes[key]['id'] = authors_citation.id.to_s
#        else
#          authors_citation = AuthorsCitation.find attribute_collection[:id]
#        end
#        authors_citation.ordering.update(position: attribute_collection[:ordering_attributes][:position])
#      end
#    end
#    super
#  end

#  def authors_attributes=(attributes)
#    attributes.each do |key, attribute_collection|
#      unless attribute_collection.has_key? 'id'
#        Author.transaction do
#          author = Author.find_or_create_by(attribute_collection)
#          authors << author unless authors.include? author
#          attributes[key]['id'] = author.id.to_s
#        end
#      end
#    end
#  end

  def keyword_ids=(tokens)
    tokens.map do |token|
      resource = Keyword.new
      save_resource_name_with_token(resource, token)
    end
    super
  end

#  def keywords_attributes=(attributes)
#    attributes.each do |key, attribute_collection|
#      unless attribute_collection.has_key? 'id'
#        Keyword.transaction do
#          keyword = Keyword.find_or_create_by!(attribute_collection)
#          keywords << keyword unless keywords.include? keyword
#          attributes[key]['id'] = keyword.id.to_s
#        end
#      end
#    end
#    super
#  end

  def year
    if journal.nil? or journal.publication_date.nil? then return '' end
    year_match = journal.publication_date.match(/[1-2][0-9][0-9][0-9]/)
    if year_match then return year_match[0] end
    return journal.publication_date
  end

  def first_author
    @fa ||= authors_citations.includes(:ordering, { citation: :authors}).order('orderings.position asc').first&.citation&.authors&.first&.name || ''
  end

  # Citation information in one line.
  def info_zinger
    citation_info = []
    citation_info << first_author if first_author
    citation_info << year if year
    citation_info << pmid if pmid
    return citation_info.join(', ')
  end

  def handle
    string_handle = ""
#    string_handle += "Study Citation: #{ name } "
#    string_handle += "(PMID: #{ pmid.to_s })" if pmid.present?
    string_handle += first_author
    string_handle += "\n"
    string_handle += year
    string_handle += "\n"
    string_handle += pmid || ''
    string_handle += "\n"
    string_handle += name || ''

    return string_handle
  end

  def label_method
    pmid.present? ?
      "<#{first_author}> <PMID: #{pmid}>" :
      name
  end
end
