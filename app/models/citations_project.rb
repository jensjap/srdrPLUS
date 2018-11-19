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
end
