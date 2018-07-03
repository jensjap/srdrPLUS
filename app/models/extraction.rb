class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  #!!! We can't implement this without ensuring integrity of the extraction form. It is possible that the database
  #    is rendered inconsistent if a project lead changes links between type1 and type2 after this hook is called.
  #    We need something that ensures consistency when linking is changed.
  #
  # Note: 6/25/2018 - We call ensure_extraction_form_structure in work and consolidate action. this might be enough
  #                   to ensure consistency?
  after_create :ensure_extraction_form_structure

  scope :by_project_and_user, -> ( project_id, user_id ) {
    joins(projects_users_role: { projects_user: :user })
    .where(project_id: project_id)
    .where(projects_users: { user_id: user_id })
  }

  scope :consolidated, -> () { where(consolidated: true) }

  belongs_to :project,             inverse_of: :extractions
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction

  delegate :citation, to: :citations_project
  delegate :user, to: :projects_users_role

#  def to_builder
#    Jbuilder.new do |extraction|
#      extraction.sections extractions_extraction_forms_projects_sections.map { |eefps| eefps.to_builder.attributes! }
#    end
#  end

  def ensure_extraction_form_structure
    self.project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
          extraction: self,
          extraction_forms_projects_section: efps,
          link_to_type1: efps.link_to_type1.nil? ?
            nil :
            ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
              extraction: self,
              extraction_forms_projects_section: efps.link_to_type1
            )
        )
      end
    end
  end

  def results_section_ready_for_extraction?
    ExtractionsExtractionFormsProjectsSectionsType1
      .by_section_name_and_extraction_id_and_extraction_forms_project_id(
        'Arms',
        self.id,
        self.project.extraction_forms_projects.first.id).present? &&
    ExtractionsExtractionFormsProjectsSectionsType1
      .by_section_name_and_extraction_id_and_extraction_forms_project_id(
        'Outcomes',
        self.id,
        self.project.extraction_forms_projects.first.id).present?
  end

  # The point is to go through all the extractions and find what they have in common.
  # Anything they have in common can be copied to the consolidated extraction (self).
  def auto_consolidate(extractions)
    # make sure the citations_projects are all the same
    if (extractions.pluck(:citations_project_id) + [self.citations_project_id]).uniq.length > 1
      #return false
    end

    # what i want to do is to build a hash to store the structure/differences
    a_hash = { }
    # for populations
    b_hash = { }
    # for timepoints
    c_hash = { }
    # for records
    d_hash = {}

    extractions.each do |extraction|
      #we need to do type1 sections first
      eefps_t1 = extraction.extractions_extraction_forms_projects_sections.
        joins(:extraction_forms_projects_section).
        where(extraction_forms_projects_sections:
              {extraction_forms_projects_section_type_id: 1})

      #then results sections
      eefps_r = extraction.extractions_extraction_forms_projects_sections.
        joins(:extraction_forms_projects_section).
        where(extraction_forms_projects_sections:
              {extraction_forms_projects_section_type_id: 3})

      #Type 1 sections
      eefps_t1.each do |eefps|
        efps = eefps.extraction_forms_projects_section
        eefps_t1s = eefps.extractions_extraction_forms_projects_sections_type1s.includes(:type1)
        eefps_t1s.each do |eefps_t1|
          type1 = eefps_t1.type1

          a_hash[efps.id.to_s] ||= {}
          a_hash[efps.id.to_s][type1.id.to_s] ||= []
          a_hash[efps.id.to_s][type1.id.to_s] << extraction.id

          # this is stylistically weird but it prevents the loop below to crash
          b_hash[efps.id.to_s] ||= {}
          b_hash[efps.id.to_s][type1.id.to_s] ||= {}

          c_hash[efps.id.to_s] ||= {}
          c_hash[efps.id.to_s][type1.id.to_s] ||= {}

          # If there are timepoints and populations, we need to consolidate those as well using a similar hash method
          eefps_t1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefps_t1_row|
            b_hash[efps.id.to_s][type1.id.to_s][eefps_t1_row.population_name_id.to_s] ||= []
            b_hash[efps.id.to_s][type1.id.to_s][eefps_t1_row.population_name_id.to_s] << extraction.id

            c_hash[efps.id.to_s][type1.id.to_s][eefps_t1_row.population_name_id.to_s] ||= {}

            eefps_t1_row.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefps_t1_row_column|
              c_hash[efps.id.to_s][type1.id.to_s][eefps_t1_row.population_name_id.to_s][eefps_t1_row_column.timepoint_name_id.to_s] ||= []
              c_hash[efps.id.to_s][type1.id.to_s][eefps_t1_row.population_name_id.to_s][eefps_t1_row_column.timepoint_name_id.to_s] << extraction.id
            end
          end
        end

        #get type1s
        #if  there are type1s  common between extractions add these  type1s to self
        #
        eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.each do |eefps_qrcf|
          # results section
          # check outcomes and  population that you know are shared
          # iterate through the sections and check  if  measures  are shared among extractions
          # make sure the data is
        end
      end

      #then type2 sections
      eefps_t2 = extraction.extractions_extraction_forms_projects_sections.
        joins(:extraction_forms_projects_section).
        where(extraction_forms_projects_sections:
              {extraction_forms_projects_section_type_id: 2})

      # now Type 2

      #iterate over type2 eefpss
      eefps_t2.each do |eefps|
        extraction = eefps.extraction
        efps = eefps.extraction_forms_projects_section
        d_hash[efps.id.to_s]  ||= {}

        #do i even need  this?
        type1s = []
        ## ruby helper (present) <==  google this
        #if eefps.link_to_type1.present? and (not !eefps.link_to_type1.type1s.empty?)
        #if eefps.link_to_type1.try(:type1s).try(:present?)
        if (not eefps.link_to_type1.nil?) and (not !eefps.link_to_type1.type1s.empty?)
          eefps.link_to_type1.type1s.each do |t1|
            # we only want to copy data if type1 is shared among all extractions
            if a_hash[efps.id.to_s][t1.id.to_s].length == extractions.length
              type1s << t1
            end
          end
        end

        # we don't want type1s to be empty, for iteration purposes
        if type1s.length == 0
          type1s << nil
        end

        # create an empty hash
        d_hash[efps.id.to_s] ||= {}

        eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.each  do |eefps_qrcf|
          # we dont want to bother with this stuff if there is no data
          if eefps_qrcf.records.first.nil?
            #byebug
            next
          end

          qrcf_id = eefps_qrcf.question_row_column_field.id.to_s

          t1_id = eefps_qrcf.extractions_extraction_forms_projects_sections_type1.present? ? eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1.id.to_s : nil

          t1_type_id = eefps_qrcf.extractions_extraction_forms_projects_sections_type1.present? ? eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1_type.id.to_s : nil

          record_name = eefps_qrcf.records.first.name

          d_hash[efps.id.to_s][t1_id] ||= {}
          d_hash[efps.id.to_s][t1_id][t1_type_id] ||= {}
          d_hash[efps.id.to_s][t1_id][t1_type_id][qrcf_id] ||= {}
          d_hash[efps.id.to_s][t1_id][t1_type_id][qrcf_id][record_name] ||= []
          d_hash[efps.id.to_s][t1_id][t1_type_id][qrcf_id][record_name] << extraction.id

          #eefps_qrcf.records.each do |records|

          #  qrc = qrcf.question_row_column
          #  qrc_t = qrc.question_row_column_type
          #  qr = qrc.question_row
          #  q =  qr.question

          #  qrc.question_row_column_options.each do ||

          #  q_t =
          #  byebug
          #end
        end
      end

    end

    #create the same type1 in self
    a_hash.each do |efps_id, a_a_hash|
      a_a_hash.each do |type1_id, t1_es|
        if t1_es.length == extractions.length
          eefps = self.extractions_extraction_forms_projects_sections.find_or_create_by!(extraction_forms_projects_section_id: efps_id)
          type1 = Type1.find(type1_id)
          eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by!(
            extractions_extraction_forms_projects_section: eefps,
            type1: type1 )

          # population and timepoint creation
          b_hash[efps_id][type1_id].each do |population_name_id, p_es|
            if p_es.length == extractions.length
              population_name = PopulationName.find(population_name_id)
              eefps_t1_row = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by!(
                extractions_extraction_forms_projects_sections_type1: eefps_t1,
                population_name: population_name )

              c_hash[efps_id][type1_id][population_name_id].each do |timepoint_name_id, t_es|
                if t_es.length == extractions.length
                  timepoint_name = TimepointName.find(timepoint_name_id)
                  ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by!(
                    extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row,
                    is_baseline: false, #should this be true in some cases?
                    timepoint_name: timepoint_name )
                end
              end
            end
          end
        end
      end
    end

    d_hash.each do |efps_id, d_d_hash|
      d_d_hash.each do |t1_id, d_d_d_hash|
        d_d_d_hash.each do |t1_type_id, d_d_d_d_hash|
          d_d_d_d_hash.each do |qrcf_id, d_d_d_d_d_hash|
            d_d_d_d_d_hash.each do |record_name, r_es|
              eefps = self.extractions_extraction_forms_projects_sections.find_or_create_by!(extraction_forms_projects_section_id: efps_id)
              qrcf = QuestionRowColumnField.find(qrcf_id)
              # what if type1 is nil
              t1 = t1_id.present? ? Type1.find(t1_id) : nil
              t1_type = t1_type_id.present? ? Type1Type.find(t1_type_id) : nil
              eefps_t1 = t1.present? ? ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by!(extractions_extraction_forms_projects_section: eefps, type1: t1, type1_type: t1_type) : nil
              eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by!(extractions_extraction_forms_projects_section: eefps, extractions_extraction_forms_projects_sections_type1: eefps_t1,  question_row_column_field: qrcf)
              record = Record.find_or_create_by!(recordable: eefps_qrcf, recordable_type: eefps_qrcf.class.name, name: record_name.dup.to_s)
              #we want to create eefps_qrcf if its not there
              #we want to
            end
          end
        end
      end
    end
    byebug

    # after going through all the extractions, we need to find_or_create_by them in the consolidated one
    # assume all eefps is there. true?

    end
  end
end
