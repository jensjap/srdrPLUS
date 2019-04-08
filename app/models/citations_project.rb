class CitationsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  #paginates_per 25

  scope :unlabeled, -> ( project, count ) { includes( :citation => [ :authors, :keywords, :journal ] )
                                            .left_outer_joins(:labels)
                                            .where( :labels => { :id => nil },
                                                    :project_id => project.id )
                                            .distinct
                                            .limit(count) }

  scope :labeled, -> ( project, count ) { includes( { :citation => [ :authors, :keywords, :journal ] , labels => [ :reasons ] } )
                                          .joins(:labels)
                                          .where(:project_id => project.id )
                                          .distinct
                                          .limit(count) }

  belongs_to :citation
  belongs_to :project

  has_one :prediction, dependent: :destroy
  has_one :priority, dependent: :destroy

  has_many :extractions, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  accepts_nested_attributes_for :citation, reject_if: :all_blank

  def label_method
    citation.pmid.present? ?
      "#{ citation.name } (PMID: #{ citation.pmid })" :
      citation.name
  end

  def dedupe
    citations_projects = CitationsProject.where(
      citation_id: self.citation_id,
      project_id: self.project_id
    ).to_a
    master_citations_project = citations_projects.shift
    citations_projects.each do |citation|
      citation.extractions.each do |e|
        e.dup.update_attributes(citations_project_id: master_citations_project.id)
      end
      citation.labels.each do |l|
        l.dup.update_attributes(citations_project_id: master_citations_project.id)
      end
      citation.notes.each do |n|
        n.dup.update_attributes(notable_id: master_citations_project.id)
      end
      citation.taggings.each do |t|
        t.dup.update_attributes(taggable_id: master_citations_project.id)
      end
      citation.destroy
    end
  end
end
