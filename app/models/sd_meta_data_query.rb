class SdMetaDataQuery < ApplicationRecord
  belongs_to :sd_meta_datum
  belongs_to :projects_user

  #delegate :project, to: :projects_user
  #delegate :user, to: :projects_user

  def query_hash= query_hash
    update( query_string: query_hash.to_query )
  end

  def query_hash
    Rack::Utils.parse_query query_string
  end

  def key_questions_projects
    kqp_ids = []
    query_hash[ 'key_questions[]' ].each do |kqp_elem|
      kqp_ids << kqp_elem[ :key_questions_project_id ]
    end
    KeyQuestionsProject.find( kqp_ids )
  end

  def arms
    eefps_ids = []
    query_hash[ 'arms[]' ].each do |eefps_elem|
      eefps_ids << eefps_elem[ :extractions_extraction_forms_projects_sections_type1_id ]
    end
    ExtractionsExtractionFormsProjectsSectionsType1.find( eefps_ids )
  end

  def outcomes
    eefps_ids = []
    query_hash[ 'outcomes[]' ].each do |eefps_elem|
      eefps_ids << eefps_elem[ :extractions_extraction_forms_projects_sections_type1_id ]
    end
    ExtractionsExtractionFormsProjectsSectionsType1.find( eefps_ids )
  end
end
