class Project < ApplicationRecord
  require 'csv'

  include SharedPublishableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail
  searchkick

  paginates_per 8

  scope :published, -> { joins(publishings: :approval) }
  scope :lead_by_current_user, -> {}

  after_create :create_default_extraction_form
  after_create :create_default_perpetual_task

  has_many :extractions, dependent: :destroy, inverse_of: :project

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :project
  has_many :extraction_forms, through: :extraction_forms_projects, dependent: :destroy

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :project
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy

  has_many :projects_studies, dependent: :destroy, inverse_of: :project
  has_many :studies, through: :projects_studies, dependent: :destroy

  has_many :projects_users, dependent: :destroy, inverse_of: :project
  has_many :projects_users_roles, through: :projects_users, dependent: :destroy
  has_many :users, through: :projects_users, dependent: :destroy

  has_many :publishings, as: :publishable, dependent: :destroy

  has_many :citations_projects, dependent: :destroy, inverse_of: :project
  has_many :citations, through: :citations_projects, dependent: :destroy

  has_many :labels, through: :citations_projects
  has_many :unlabeled_citations, ->{ where( :labels => { :id => nil } ) }, through: :citations_projects, source: :citations

  has_many :tasks, dependent: :destroy, inverse_of: :project
  has_many :assignments, through: :tasks, dependent: :destroy

  validates :name, presence: true

  #accepts_nested_attributes_for :extraction_forms_projects, reject_if: :all_blank, allow_destroy: true
  #accepts_nested_attributes_for :key_questions_projects, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :citations
  accepts_nested_attributes_for :citations_projects, allow_destroy: true
  accepts_nested_attributes_for :tasks, allow_destroy: true
  accepts_nested_attributes_for :assignments, allow_destroy: true

  def public?
    self.publishings.any?(&:approval)
  end

  def duplicate_key_question?
    self.key_questions.having('count(*) > 1').group('name').length.nonzero?
  end

  def duplicate_extraction_form?
    self.extraction_forms.having('count(*) > 1').group('name').length.nonzero?
  end

  def key_questions_projects_array_for_select
    self.key_questions_projects.map { |kqp| [kqp.key_question.name, kqp.id] }
  end

  def leaders
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
      .where(projects_users: { project_id: id })
      .where(projects_users: { projects_users_roles: { roles: { name: 'Leader' } } })
  end

  def contributors
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
      .where(projects_users: { project_id: id })
      .where(projects_users: { projects_users_roles: { roles: { name: 'Contributor' } } })
  end

  def auditors
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
      .where(projects_users: { project_id: id })
      .where(projects_users: { projects_users_roles: { roles: { name: 'Auditor' } } })
  end

  def members
    User.joins({ projects_users: :project })
      .where(projects_users: { project_id: id })
  end

  def consolidated_extraction(citations_project_id, current_user_id)
    consolidated_extraction = self.extractions.consolidated.find_by(citations_project_id: citations_project_id)
    return consolidated_extraction if consolidated_extraction.present?
    return self.extractions.create(
      citations_project_id: citations_project_id,
      projects_users_role: ProjectsUsersRole.find_or_create_by!(
        projects_user: ProjectsUser.find_by(project: self, user_id: current_user_id),
        role: Role.find_by(name: 'Consolidator')),
      consolidated: true)
  end

  # returns nested hash:
  # {
  #   key: citations_project_id
  #   value: {
  #     data_discrepancy: Bool,
  #     extraction_ids: Array,
  #   },
  #   ...
  # }
  def citation_groups
    citation_groups = Hash.new
    citation_groups[:citations_projects] = Hash.new
    citation_groups[:citations_project_ids] = Array.new
    citation_groups[:citations_project_count] = 0
    self.extractions.each do |e|
      if citation_groups[:citations_projects].keys.include? e.citations_project_id
        citation_groups[:citations_projects][e.citations_project_id][:extraction_ids] << e.id

        # If data_discrepancy is true then check for the existence of a consolidated
        # extraction and skip the discovery process.
        # Else run the discovery process.
        if citation_groups[:citations_projects][e.citations_project_id][:data_discrepancy]

          # We may skip this if we already determined that a consolidated extraction exists.
          unless citation_groups[:citations_projects][e.citations_project_id][:consolidated_status]
            citation_groups[:citations_projects][e.citations_project_id][:consolidated_status] = e.consolidated
          end

        else citation_groups[:citations_projects][e.citations_project_id][:data_discrepancy]
          citation_groups[:citations_projects][e.citations_project_id][:data_discrepancy] =
            discover_extraction_discrepancy(citation_groups[:citations_projects][e.citations_project_id][:extraction_ids].first, e.id)
        end

      else
        citation_groups[:citations_project_count] += 1
        citation_groups[:citations_project_ids] << e.citations_project_id
        citation_groups[:citations_projects][e.citations_project_id] = Hash.new
        citation_groups[:citations_projects][e.citations_project_id][:citations_project_id] = e.citations_project_id
        citation_groups[:citations_projects][e.citations_project_id][:citation_name_short]  = e.citations_project.citation.name.truncate(32)
        citation_groups[:citations_projects][e.citations_project_id][:citation_name_long]   = e.citations_project.citation.name
        citation_groups[:citations_projects][e.citations_project_id][:data_discrepancy]     = false
        citation_groups[:citations_projects][e.citations_project_id][:extraction_ids]       = [e.id]
        citation_groups[:citations_projects][e.citations_project_id][:consolidated_status]  = e.consolidated
      end

      # Remove the consolidated extraction from the list of extraction_ids.
      citation_groups[:citations_projects][e.citations_project_id][:extraction_ids].delete(e.id) if e.consolidated
    end

    return citation_groups
  end

  def import_citations_from_csv( file )
    primary_id = CitationType.find_by( name: 'Primary' ).id
    secondary_id = CitationType.find_by( name: 'Secondary' ).id
    
    row_d = { 'Primary' => primary_id, 'primary' => primary_id, 
              'Secondary' => secondary_id, 'secondary' => secondary_id,
              '' => nil }

    h_arr = [] 
    CSV.foreach( file.path, headers: :true ) do |row|
      key_counter = 0
      row_h = row.to_h

      ### file encoding causes weird problems
      
      ### citation type, not sure if necessary
      cit_type = row_h[ 'type' ]
      if cit_type.present?
        row_h[ 'citation_type_id' ] = row_d[ cit_type ]  
      end
      row_h.delete 'type'

      ### keywords
      kw_str = row_h[ 'keywords' ] 
      if kw_str.present?
        kw_arr = {}
        kw_str.split( '; ' ).each do |kw|
          kw_arr[Time.now.to_i + key_counter] = { name: kw }
          key_counter+=1
        end
        row_h[ 'keywords_attributes' ] = kw_arr
      end
      row_h.delete( 'keywords' )

      ### authors
      au_str = row_h[ 'authors' ] 
      if au_str.present?
        au_arr = {}
        au_str.split( '; ' ).each do |au|
          au_arr[Time.now.to_id + key_counter] = { name: au }
          key_counter+=1
        end
        row_h[ 'authors_attributes' ] = au_arr
      end
      row_h.delete( 'authors' )

      ### journal
      j_h = {}
      if row_h.has_key? 'name' then j_h[ 'name' ] = row_h[ 'journal' ].strip end
      if row_h.has_key? 'publication_date' then _h[ 'publication_date' ] = row_h[ 'publication_date' ].strip end
      if row_h.has_key? 'volume' then _h[ 'volume' ] = row_h[ 'volume' ].strip end
      if row_h.has_key? 'issue' then _h[ 'issue' ] = row_h[ 'issue' ].strip end
      row_h[ 'journal_attributes' ] = j_h
      row_h.delete( 'journal' )
      row_h.delete( 'publication_date' )
      row_h.delete( 'volume' )
      row_h.delete( 'issue' )

      h_arr << row_h
    end

    self.citations << Citation.create!( h_arr )
  end

  def import_citations_from_pubmed( file )
    key_counter = 0
    pmid_arr = File.readlines( file.path )
    primary_id = CitationType.find_by( name: 'Primary' ).id

    h_arr = [] 
    Bio::PubMed.efetch( pmid_arr ).each do |cit_txt|
      row_h = {}
      cit_h = Bio::MEDLINE.new( cit_txt ).pubmed
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      if cit_h[ 'PMID' ].present? then row_h[ 'pmid' ] = cit_h[ 'PMID' ].strip end
      if cit_h[ 'TI' ].present? then row_h[ 'name' ] = cit_h[ 'TI' ].strip end
      if cit_h[ 'AB' ].present? then row_h[ 'abstract' ] = cit_h[ 'AB' ].strip end
      row_h[ 'citation_type_id' ] = primary_id
      
      #keywords
      if cit_h[ 'OT' ].present? 
        kw_arr = cit_h[ 'OT' ].split( "\n" )
        row_h[ 'keywords_attributes' ] = {}
        kw_arr.each do |kw|
          row_h[ 'keywords_attributes' ][Time.now.to_i + key_counter] = { name: kw }
          key_counter+=1
        end
      end

      #authors
      if cit_h[ 'AU' ].present? 
        au_arr = cit_h[ 'AU' ].split( "\n" )
        row_h[ 'authors_attributes' ] = {} 
        au_arr.each do |au|
          row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
          key_counter+=1
        end
      end

      #journal
      j_h = {}
      if cit_h[ 'TA' ].present? then j_h[ 'name' ] = cit_h[ 'TA' ].strip end
      if cit_h[ 'DP' ].present? then j_h[ 'publication_date' ] = cit_h[ 'DP' ].strip end
      if cit_h[ 'VI' ].present? then j_h[ 'volume' ] = cit_h[ 'VI' ].strip end
      if cit_h[ 'IP' ].present? then j_h[ 'issue' ] = cit_h[ 'IP' ].strip end
      row_h[ 'journal_attributes' ] = j_h

      h_arr << row_h
    end
    self.citations << Citation.create!( h_arr )
  end

  def import_citations_from_ris( file )
    key_counter = 0
    primary_id = CitationType.find_by( name: 'Primary' ).id

    # creates a new parser of type RIS
    parser = RefParsers::RISParser.new

    file_string = ""
    File.readlines(file.path).each do |line|
      file_string += line.strip_control_and_extended_characters() + "\n"
    end
    
    h_arr = [] 
    parser.parse( file_string ).each do |cit_h|
      row_h = {}
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      ## NOT SURE ABOUT PMID KEY
      if cit_h[ 'AN' ].present? then row_h[ 'pmid' ] = cit_h[ 'AN' ].strip end
      if cit_h[ 'TI' ].present? then row_h[ 'name' ] = cit_h[ 'TI' ].strip end
      if cit_h[ 'AB' ].present? then row_h[ 'abstract' ] = cit_h[ 'AB' ].strip end
      row_h[ 'citation_type_id' ] = primary_id
      
      #keywords
      if cit_h[ 'KW' ].present? 
        kw_arr = cit_h[ 'KW' ].split( "     " )
        row_h[ 'keywords_attributes' ] = {}
        kw_arr.each do |kw|
          row_h[ 'keywords_attributes' ][Time.now.to_i + key_counter] = { name: kw }
          key_counter+=1
        end
      end

      #authors
      if cit_h[ 'AU' ].present? 
        au_arr = cit_h[ 'AU' ]
        row_h[ 'authors_attributes' ] = {}
        au_arr.each do |au|
          row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
          key_counter+=1
        end
      end

      #journal
      j_h = {}
      if cit_h[ 'T2' ].present? then j_h[ 'name' ] = cit_h[ 'T2' ].strip end
      if cit_h[ 'PY' ].present? then j_h[ 'publication_date' ] = cit_h[ 'PY' ].strip end
      if cit_h[ 'VL' ].present? then j_h[ 'volume' ] = cit_h[ 'VL' ].strip end
      if cit_h[ 'IS' ].present? then j_h[ 'issue' ] = cit_h[ 'IS' ].strip end
      row_h[ 'journal_attributes' ] = j_h

      h_arr << row_h
    end
    self.citations << Citation.create!( h_arr )
  end

  private

    #def separate_pubmed_keywords( kw_string )
    #  return kw_string.split( "; " ).map { |str| str.strip }
    #end

    def create_default_extraction_form
      self.extraction_forms_projects.create!(extraction_forms_project_type: ExtractionFormsProjectType.first, extraction_form: ExtractionForm.first)
    end

    def create_default_perpetual_task
      new_task = self.tasks.create!(task_type: TaskType.find_by(name: 'Perpetual'))
      #ProjectsUsersRole.by_project(@project).each do |pur|
      #  new_task.assignments << Assignment.create!(projects_users_role: pur)
      #end
    end

    def discover_extraction_discrepancy(extraction1_id, extraction2_id)
      e1 = Extraction.find(extraction1_id)
      e1_json = ApplicationController.new.view_context.render(
        partial: 'extractions/extraction_for_comparison_tool',
        locals: { extraction: e1 },
        formats: [:json],
        handlers: [:jbuilder]
      )
      e2 = Extraction.find(extraction2_id)
      e2_json = ApplicationController.new.view_context.render(
        partial: 'extractions/extraction_for_comparison_tool',
        locals: { extraction: e2 },
        formats: [:json],
        handlers: [:jbuilder]
      )
#      e1_json = e1.to_builder.target!
#      e2_json = e2.to_builder.target!

      return not(e1_json.eql? e2_json)
    end
end
