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
  after_create :create_default_member

  has_many :extractions, dependent: :destroy, inverse_of: :project

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :project
  has_many :extraction_forms, through: :extraction_forms_projects, dependent: :destroy

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :project
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy
  ## this does not feel right - Birol
  has_many :orderings, through: :key_questions_projects, dependent: :destroy

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
  accepts_nested_attributes_for :key_questions_projects, allow_destroy: true
  accepts_nested_attributes_for :orderings
  accepts_nested_attributes_for :projects_users, allow_destroy: true


  def public?
    self.publishings.any?(&:approval)
  end

  def duplicate_key_question?
    self.key_questions.select('name').having('count(*) > 1').group('name').length.nonzero?
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
    ### citation type, not sure if necessary
    #secondary_id = CitationType.find_by( name: 'Secondary' ).id
    #
    #row_d = { 'Primary' => primary_id, 'primary' => primary_id,
    #          'Secondary' => secondary_id, 'secondary' => secondary_id,
    #          '' => nil }

    h_arr = []

    file_data = File.read( file.path ).gsub(/(\r\n|\r|\n)/, "\n")
    file_string = ""
    ### open file using 'rU'
    file_data.split("\n").each do |line|
      file_string += ( line.strip_control_and_extended_characters() + "\n" )
    end

    CSV.parse( file_string, headers: :true ) do |row|
      key_counter = 0
      row_h = row.to_h
      cit_h = {}

      ### file encoding causes weird problems

      ### citation type, not sure if necessary
      #cit_type = row_h[ 'type' ]
      #if cit_type.present?
      #  row_h[ 'citation_type_id' ] = row_d[ cit_type ]
      #else
      #  row_h[ 'citation_type_id' ] = primary_id
      #end
      #row_h.delete 'type'
      cit_h[ 'citation_type_id' ] = primary_id


      ### keywords
      kw_str = row_h[ 'Keywords' ]
      if kw_str.present?
        kw_str.gsub! /"/, ''
        kw_arr = kw_str.split( "     " )
        if kw_arr.length == 1 then kw_arr = kw_str.split( /, |,/ ) end
        if kw_arr.length == 1 then kw_arr = kw_str.split( / \/ |\// ) end
        if kw_arr.length == 1 then kw_arr = kw_str.split( / \| |\|/ ) end
        if kw_arr.length == 1 then kw_arr = kw_str.split( /\n| \n/ ) end

        cit_h[ 'keywords_attributes' ] = {}
        kw_arr.each do |kw|
          cit_h[ 'keywords_attributes' ][Time.now.to_i + key_counter] = { name: kw }
          key_counter+=1
        end
      end

      ### authors
      au_str = row_h[ 'Author' ]
      if au_str.present?
        au_str.gsub! /"/, ''
        au_arr = au_str.split( "     " )
        if au_arr.length == 1 then au_arr = au_str.split( /, |,/ ) end
        if au_arr.length == 1 then au_arr = au_str.split( / \/ |\// ) end
        if au_arr.length == 1 then au_arr = au_str.split( / \| |\|/ ) end
        if au_arr.length == 1 then au_arr = au_str.split( /\n| \n/ ) end

        cit_h[ 'authors_attributes' ] = {}
        au_arr.each do |au|
          cit_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
          key_counter+=1
        end
      end

      ### journal
      j_h = {}
      if row_h[ 'Journal' ].present? then j_h[ 'name' ] = row_h[ 'Journal' ].strip end
      if row_h[ 'Year' ].present? then j_h[ 'publication_date' ] = row_h[ 'Year' ].strip end
      if row_h[ 'Volume' ].present? then j_h[ 'volume' ] = row_h[ 'Volume' ].strip end
      if row_h[ 'Issue' ].present? then j_h[ 'issue' ] = row_h[ 'Issue' ].strip end
      cit_h[ 'journal_attributes' ] = j_h


      if row_h[ 'Title' ].present? then cit_h[ 'name' ] = row_h[ 'Title' ].strip end
      if row_h[ 'Abstract' ].present? then cit_h[ 'abstract' ] = row_h[ 'Abstract' ].strip end
      if row_h[ 'Accession Number' ].present? then cit_h[ 'pmid' ] = row_h[ 'Accession Number' ].strip end

      h_arr << cit_h
    end

    self.citations << Citation.create!( h_arr )
  end

  def import_citations_from_pubmed( file )
    key_counter = 0

    # Let's ensure that the list of PMIDs has pure integers and unique entries.
    pmid_arr    = File.readlines( file.path ).map(&:chomp).map(&:to_i).uniq
    primary_id  = CitationType.find_by( name: 'Primary' ).id
    h_arr       = []

    citations_already_in_system, citations_need_fetching = process_list_of_pmids(pmid_arr)

    Bio::PubMed.efetch( citations_need_fetching ).each do |cit_txt|
      row_h = {}
      cit_h = Bio::MEDLINE.new( cit_txt ).pubmed
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      if cit_h[ 'PMID' ].present? then row_h[ 'pmid' ]     = cit_h[ 'PMID' ].strip end
      if cit_h[ 'TI' ].present?   then row_h[ 'name' ]     = cit_h[ 'TI' ].strip end
      if cit_h[ 'AB' ].present?   then row_h[ 'abstract' ] = cit_h[ 'AB' ].strip end
      row_h[ 'citation_type_id' ] = primary_id

      #keywords
      if cit_h[ 'OT' ].present?
        kw_str = cit_h[ 'OT' ]
        kw_str.gsub! /"/, ''
        kw_arr = kw_str.split( "     " )
        if kw_arr.length == 1 then kw_arr = kw_str.split( /, |,/ ) end
        if kw_arr.length == 1 then kw_arr = kw_str.split( / \/ |\// ) end
        if kw_arr.length == 1 then kw_arr = kw_str.split( / \| |\|/ ) end
        if kw_arr.length == 1 then kw_arr = kw_str.split( /\n| \n/ ) end
        row_h[ 'keywords_attributes' ] = {}
        kw_arr.each do |kw|
          row_h[ 'keywords_attributes' ][Time.now.to_i + key_counter] = { name: kw }
          key_counter+=1
        end
      end

      #authors
      if cit_h[ 'AU' ].present?
        au_str = cit_h[ 'AU' ]
        au_str.gsub! /"/, ''
        au_arr = au_str.split( "     " )
        if au_arr.length == 1 then au_arr = au_str.split( /, |,/ ) end
        if au_arr.length == 1 then au_arr = au_str.split( / \/ |\// ) end
        if au_arr.length == 1 then au_arr = au_str.split( / \| |\|/ ) end
        if au_arr.length == 1 then au_arr = au_str.split( /\n| \n/ ) end
        row_h[ 'authors_attributes' ] = {}
        au_arr.each do |au|
          row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
          key_counter+=1
        end
      end

      #journal
      j_h = {}
      if cit_h[ 'TA' ].present? then j_h[ 'name' ]             = cit_h[ 'TA' ].strip end
      if cit_h[ 'DP' ].present? then j_h[ 'publication_date' ] = cit_h[ 'DP' ].strip end
      if cit_h[ 'VI' ].present? then j_h[ 'volume' ]           = cit_h[ 'VI' ].strip end
      if cit_h[ 'IP' ].present? then j_h[ 'issue' ]            = cit_h[ 'IP' ].strip end
      row_h[ 'journal_attributes' ] = j_h

      h_arr << row_h
    end

    self.citations << Citation.create!( h_arr )
    self.citations << citations_already_in_system
  end

  def import_citations_from_ris( file )
    key_counter = 0
    primary_id = CitationType.find_by( name: 'Primary' ).id

    # creates a new parser of type RIS
    parser = RefParsers::RISParser.new

    file_data = File.read( file.path ).gsub(/(\r\n|\r|\n)/, "\n")
    file_string = ""
    ### open file using 'rU'
    file_data.split("\n").each do |line|
      file_string += ( line.strip_control_and_extended_characters() + "\n" )
    end

    h_arr = []
    parser.parse( file_string ).each do |cit_h|
      row_h = {}
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      ## NOT SURE ABOUT PMID KEY
      if cit_h[ 'AN' ].present? then row_h[ 'pmid' ] = cit_h[ 'AN' ].strip end
      if cit_h[ 'TI' ].present? then row_h[ 'name' ] = cit_h[ 'TI' ].strip end
      if cit_h[ 'T1' ].present? then row_h[ 'name' ] = cit_h[ 'T1' ].strip end
      if cit_h[ 'AB' ].present? then row_h[ 'abstract' ] = cit_h[ 'AB' ].strip end
      row_h[ 'citation_type_id' ] = primary_id

      #keywords
      if cit_h[ 'KW' ].present?
        ### splitting kw strings still a huge pain
        kw_arr = []
        if cit_h[ 'KW' ].is_a? Enumerable
          kw_arr = cit_h[ 'KW' ]
        else
          kw_arr = cit_h[ 'KW' ].split( "     " )
        end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( /, |,/ ) end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( / \/ |\// ) end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( / \| |\|/ ) end
        row_h[ 'keywords_attributes' ] = {}
        kw_arr.each do |kw|
          row_h[ 'keywords_attributes' ] [Time.now.to_i + key_counter ] = { name: kw }
          key_counter += 1
        end
      end

      row_h[ 'authors_attributes' ] = {}

      ##authors
      #if cit_h[ 'AU' ].present?
      #  au_arr = cit_h[ 'AU' ]
      #  au_arr.each do |au|
      #    row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
      #    key_counter+=1
      #  end
      #end

      #there are other tags for authors
      [ "A1", "A2", "A3", "A4", "AU" ].each do |au_key|
        if cit_h[ au_key ].present?
          au_arr = []
          if cit_h[ au_key ].is_a? Enumerable
            au_arr = cit_h[ au_key ]
          else
            au_arr = cit_h[ au_key ].split( "     " )
          end
          au_arr.each do |au|
            row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
            key_counter += 1
          end
        end
      end

      #journal
      j_h = {}
      if cit_h[ 'T2' ].present? then j_h[ 'name' ] = cit_h[ 'T2' ].strip end
      if cit_h[ 'JF' ].present? then j_h[ 'name' ] = cit_h[ 'JF' ].strip end
      if cit_h[ 'JO' ].present? then j_h[ 'name' ] = cit_h[ 'JO' ].strip end
      if cit_h[ 'PY' ].present? then j_h[ 'publication_date' ] = cit_h[ 'PY' ].strip end
      if cit_h[ 'Y1' ].present? then j_h[ 'publication_date' ] = cit_h[ 'Y1' ].strip end
      if cit_h[ 'VL' ].present? then j_h[ 'volume' ] = cit_h[ 'VL' ].strip end
      if cit_h[ 'IS' ].present? then j_h[ 'issue' ] = cit_h[ 'IS' ].strip end
      row_h[ 'journal_attributes' ] = j_h

      h_arr << row_h
    end
    self.citations << Citation.create!( h_arr )
  end

  def import_citations_from_enl( file )
    key_counter = 0
    primary_id = CitationType.find_by( name: 'Primary' ).id

    # creates a new parser of type EndNote
    parser = RefParsers::EndNoteParser.new

    file_data = File.read( file.path ).gsub(/(\r\n|\r|\n)/, "\n")
    file_string = ""
    ### open file using 'rU'
    file_data.split("\n").each do |line|
      file_string += ( line.strip_control_and_extended_characters() + "\n" )
    end

    h_arr = []
    parser.parse( file_string ).each do |cit_h|
      row_h = {}
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      ## NOT SURE ABOUT PMID KEY
      if cit_h[ 'M' ].present? then row_h[ 'pmid' ] = cit_h[ 'M' ].strip end
      if cit_h[ 'T' ].present? then row_h[ 'name' ] = cit_h[ 'T' ].strip end
      if cit_h[ 'X' ].present? then row_h[ 'abstract' ] = cit_h[ 'X' ].strip end
      row_h[ 'citation_type_id' ] = primary_id

      #keywords
      if cit_h[ 'K' ].present?
        ### splitting kw strings still a huge pain
        kw_arr = []
        if cit_h[ 'K' ].is_a? Enumerable
          kw_arr = cit_h[ 'K' ]
        else
          kw_arr = cit_h[ 'K' ].split( "     " )
        end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'K' ].split( /, |,/ ) end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'K' ].split( / \/ |\// ) end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'K' ].split( / \| |\|/ ) end
        if kw_arr.length == 1 then kw_arr = kw_str.split( /\n| \n/ ) end

        row_h[ 'keywords_attributes' ] = {}
        kw_arr.each do |kw|
          row_h[ 'keywords_attributes' ] [Time.now.to_i + key_counter ] = { name: kw }
          key_counter += 1
        end
      end

      row_h[ 'authors_attributes' ] = {}

      ##authors
      #if cit_h[ 'AU' ].present?
      #  au_arr = cit_h[ 'AU' ]
      #  au_arr.each do |au|
      #    row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
      #    key_counter+=1
      #  end
      #end

      #there are other tags for authors
      [ "A" ].each do |au_key|
        if cit_h[ au_key ].present?
          au_arr = []
          if cit_h[ au_key ].is_a? Enumerable
            au_arr = cit_h[ au_key ]
          else
            au_arr = cit_h[ au_key ].split( "     " )
          end
          au_arr.each do |au|
            row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
            key_counter += 1
          end
        end
      end

      #journal
      j_h = {}
      if cit_h[ 'B' ].present? then j_h[ 'name' ] = cit_h[ 'B' ].strip end
      if cit_h[ 'D' ].present? then j_h[ 'publication_date' ] = cit_h[ 'D' ].strip end
      if cit_h[ 'V' ].present? then j_h[ 'volume' ] = cit_h[ 'V' ].strip end
      if cit_h[ 'I' ].present? then j_h[ 'issue' ] = cit_h[ 'I' ].strip end
      row_h[ 'journal_attributes' ] = j_h

      h_arr << row_h
    end
    self.citations << Citation.create!( h_arr )
  end

  def has_duplicate_citations?
    citations_projects
      .select(:citation_id, :project_id)
      .group(:citation_id, :project_id)
      .having("count(*) > 1").length > 1
  end

  def dedupe_citations
    citations_projects
      .group(:citation_id, :project_id)
      .having("count(*) > 1")
      .each do |cp|
      cp.dedupe
    end
  end

  private
    def process_list_of_pmids(listOf_pmids)
      citations_already_in_system = []
      citations_need_fetching     = []

      listOf_pmids.each do |pmid|
        if c = Citation.find_by(pmid: pmid)
          citations_already_in_system << c
        else
          citations_need_fetching << pmid
        end
      end

      return citations_already_in_system, citations_need_fetching
    end

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

    def create_default_member
      if User.try(:current)
        self.users << User.current
        self.projects_users.first.roles << Role.first
        self.save
      end
    end
end
