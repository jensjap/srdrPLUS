# == Schema Information
#
# Table name: citations
#
#  id                :integer          not null, primary key
#  citation_type_id  :integer
#  name              :string(500)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  refman            :string(255)
#  pmid              :string(255)
#  abstract          :binary(65535)
#  page_number_start :string(255)
#  page_number_end   :string(255)
#  registry_number   :string(255)
#  doi               :string(255)
#  other             :string(255)
#  accession_number  :string(255)
#  authors           :text(65535)
#

class Citation < ApplicationRecord
  include SharedQueryableMethods
  include SharedProcessTokenMethods

  searchkick callbacks: :async

  after_commit :reindex_citations_projects

  belongs_to :citation_type, optional: true

  has_one :journal, dependent: :nullify

  has_many :citations_projects, dependent: :destroy, inverse_of: :citation
  has_many :projects, through: :citations_projects
  has_and_belongs_to_many :keywords, dependent: :destroy

  accepts_nested_attributes_for :keywords, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :journal, reject_if: :all_blank, allow_destroy: true

  # Redundant?
  def abstract_utf8
    abstract = read_attribute(:abstract)
    abstract.nil? ? '' : abstract.encode('utf-8', invalid: :replace, undef: :replace, replace: '_')
  end

  # Without this Searchkick cannot create indices
  def abstract
    (read_attribute(:abstract) || '').force_encoding('UTF-8')
  end

  def accession_number_alts
    (pmid.present? && pmid) ||
      (registry_number.present? && registry_number) ||
      (refman.present? && refman) ||
      (accession_number.present? && accession_number) ||
      (doi.present? && doi) ||
      (other.present? && other)
  end

  def keyword_ids=(tokens)
    tokens.map do |token|
      resource = Keyword.new
      save_resource_name_with_token(resource, token)
    end
    super
  end

  def year
    return '' if journal.nil? or journal.publication_date.nil?

    year_match = journal.publication_date.match(/[1-2][0-9][0-9][0-9]/)
    return year_match[0] if year_match

    journal.publication_date
  end

  # Citation information in one line.
  def info_zinger
    citation_info = []
    citation_info << authors if authors
    citation_info << year if year
    citation_info << pmid if pmid
    citation_info.join(', ')
  end

  def handle
    string_handle = ''
    string_handle += authors
    string_handle += "\n"
    string_handle += year
    string_handle += "\n"
    string_handle += pmid || ''
    string_handle += "\n"
    string_handle += name || ''

    string_handle
  end

  def label_method
    if pmid.present?
      "<#{authors}> <PMID: #{pmid}>"
    else
      "<#{authors}> #{name}"
    end
  end

  def reindex_citations_projects
    citations_projects.each(&:reindex)
  end
end
