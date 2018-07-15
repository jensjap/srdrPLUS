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
    # for arms
    t1_hash = {}
    # for populations
    p_hash = {}
    # for timepoints
    tp_hash = {}
    # for records
    r_hash = {}
    # for rssms
    rssm_hash = {}
    # for comparisons, this one stores array of comparison ids instead of extraction ids
    c_hash = {}
    # for rssm 3-way join tables
    three_hash = {}
    # store cloned comparisons
    cloned_c_hash = {}
    # store result records
    result_r_hash = {}

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
        efps_id = eefps.extraction_forms_projects_section_id.to_s
        eefps_t1s = eefps.extractions_extraction_forms_projects_sections_type1s.includes(:type1)
        eefps_t1s.each do |eefps_t1|
          type1 = eefps_t1.type1
          type1_id = type1.id.to_s

          t1_hash[efps_id] ||= {}
          t1_hash[efps_id][type1_id] ||= []
          t1_hash[efps_id][type1_id] << extraction.id

          # this is stylistically weird but it prevents the loop below to crash
          p_hash[efps_id] ||= {}
          p_hash[efps_id][type1_id] ||= {}

          tp_hash[efps_id] ||= {}
          tp_hash[efps_id][type1_id] ||= {}

          rssm_hash[efps_id] ||= {}
          rssm_hash[efps_id][type1_id] ||= {}

          c_hash[efps_id] ||= {}
          c_hash[efps_id][type1_id] ||= {}

          three_hash[efps_id] ||= {}
          three_hash[efps_id][type1_id] ||= {}

          result_r_hash[efps_id] ||= {}
          result_r_hash[efps_id][type1_id] ||= {}


          # If there are timepoints and populations, we need to consolidate those as well using a similar hash method
          eefps_t1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefps_t1_row|
            population_name_id = eefps_t1_row.population_name_id.to_s

            p_hash[efps_id][type1_id][population_name_id] ||= []
            p_hash[efps_id][type1_id][population_name_id] << extraction.id

            tp_hash[efps_id][type1_id][population_name_id] ||= {}
            rssm_hash[efps_id][type1_id][population_name_id] ||= {}
            c_hash[efps_id][type1_id][population_name_id] ||= {}
            three_hash[efps_id][type1_id][population_name_id] ||= {}
            result_r_hash[efps_id][type1_id][population_name_id] ||= {}

            eefps_t1_row.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefps_t1_row_column|
              tp_name_id = eefps_t1_row_column.timepoint_name_id.to_s
              tp_hash[efps_id][type1_id][population_name_id][tp_name_id] ||= []
              tp_hash[efps_id][type1_id][population_name_id][tp_name_id] << extraction.id
            end

            eefps_t1_row.result_statistic_sections.each do |rss|
              rss_type_id = rss.result_statistic_section_type_id.to_s

              rssm_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}
              c_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}
              three_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}
              result_r_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}

              rss.comparisons.each do |comparison|
                # thank the maker for pretty_print_export_header --Birol
                comparison_name = comparison.tokenize

                c_hash[efps_id][type1_id][population_name_id][rss_type_id][comparison_name] ||= []
                c_hash[efps_id][type1_id][population_name_id][rss_type_id][comparison_name] << comparison.id

              end

              rss.result_statistic_sections_measures.each do |rssm|
                measure_id = rssm.measure_id.to_s

                rssm_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] ||= []
                rssm_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] << extraction.id

                three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] ||= {}
                result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] ||= {}

                case rss_type_id
                when "1"
                  rssm.tps_arms_rssms.each do |tps_arms_rssm|
                    tp_name_id = tps_arms_rssm.timepoint.timepoint_name_id.to_s
                    arm_efps_id = tps_arms_rssm.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.id
                    arm_name_id = tps_arms_rssm.extractions_extraction_forms_projects_sections_type1.type1_id
                    record_name = tps_arms_rssm.records.first.name

  #                  num_extractions_tp = tp_hash[efps_id][type1_id][population_name_id][eefps_t1_row_column.tp_name_id.to_s].length
  #                  num_extractions_arm = t1_hash[efps_id][type1_id].length
  #
  #                  if num_extractions_tp < extractions.length or 
  #                      num_extractions_arm < extractions.length
  #                    next
  #                  end

                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][arm_efps_id] ||= {}
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][arm_efps_id][arm_name_id] ||= []
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][arm_efps_id][arm_name_id] << extraction.id
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][arm_efps_id] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][arm_efps_id][arm_name_id] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][arm_efps_id][arm_name_id][record_name] ||= []
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][arm_efps_id][arm_name_id][record_name] << extraction.id
                  end

                when "2"
                  rssm.tps_comparisons_rssms.each do |tps_comparisons_rssm|
                    tp_name_id = tps_comparisons_rssm.timepoint.timepoint_name_id
                    comparison_name = tps_comparisons_rssm.comparison.tokenize
                    record_name = tps_comparisons_rssm.records.first.name

  #                  num_extractions_tp = tp_hash[efps_id][type1_id][population_name_id][eefps_t1_row_column.tp_name_id.to_s].length
  #                  num_extractions_comparison = c_hash[efps_id][type1_id][population_name_id][rss_type_id][comparison_name].length
  #
  #
  #                  if num_extractions_tp < extractions.length or 
  #                      num_extractions_comparison < extractions.length
  #                    next
  #                  end

                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][comparison_name] ||= []
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][comparison_name] << extraction.id
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][comparison_name] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][comparison_name][record_name] ||= []
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][comparison_name][record_name] << extraction.id
                  end

                when "3"
                  rssm.comparisons_arms_rssms.each do |comparisons_arms_rssm|
                    comparison_name = comparisons_arms_rssm.comparison.tokenize
                    arm_efps_id = comparisons_arms_rssm.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.id
                    arm_name_id = comparisons_arms_rssm.extractions_extraction_forms_projects_sections_type1.type1_id
                    record_name = comparisons_arms_rssm.records.first.name

  #                  num_extractions_comparison = tp_hash[efps_id][type1_id][population_name_id][eefps_t1_row_column.tp_name_id.to_s].length
  #                  num_extractions_arm = t1_hash[efps_id][type1_id].length
  #
  #
  #                  if num_extractions_comparison < extractions.length or 
  #                      num_extractions_arm < extractions.length
  #                    next
  #                  end

                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name] ||= {}
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id] ||= {}
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id] ||= []
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id] << extraction.id
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id][record_name] ||= []
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id][record_name] << extraction.id
                  end

                when "4"
                  rssm.wacs_bacs_rssms.each do |wacs_bacs_rssm|
                    wac_name = wacs_bacs_rssm.wac.tokenize
                    bac_name = wacs_bacs_rssm.bac.tokenize
                    record_name = wacs_bacs_rssm.records.first.name

  #                  num_extractions_wac = c_hash[efps_id][type1_id][population_name_id][rss_type_id][wac_name].length
  #                  num_extractions_bac = c_hash[efps_id][type1_id][population_name_id][rss_type_id][bac_name].length
  #
  #                  if num_extractions_wac < extractions.length or
  #                      num_extractions_bac < extractions.length
  #                    next
  #                  end

                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name] ||= {}
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name] ||= []
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name] << extraction.id

                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name] ||= {}
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name][record_name] ||= []
                    result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name][record_name] << extraction.id
                  end

                else
                  byebug
                end
              end
            end
          end
        end

        #get type1s
        #if  there are type1s  common between extractions add these  type1s to self
        
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
        efps_id = efps.id.to_s
        r_hash[efps_id]  ||= {}

        #do i even need  this?
        type1s = []
        ## ruby helper (present) <==  google this
        #if eefps.link_to_type1.present? and (not !eefps.link_to_type1.type1s.empty?)
        #if eefps.link_to_type1.try(:type1s).try(:present?)
        if (not eefps.link_to_type1.nil?) and (not !eefps.link_to_type1.type1s.empty?)
          eefps.link_to_type1.type1s.each do |t1|
            # we only want to copy data if type1 is shared among all extractions
            if t1_hash[efps_id][t1.id.to_s].length == extractions.length
              type1s << t1
            end
          end
        end

        # we don't want type1s to be empty, for iteration purposes
        if type1s.length == 0
          type1s << nil
        end

        # create an empty hash
        r_hash[efps_id] ||= {}

        eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.each do |eefps_qrcf|
          # we dont want to bother with this stuff if there is no data
          if eefps_qrcf.records.first.nil?
            #byebug
            next
          end

          qrcf_id = eefps_qrcf.question_row_column_field.id.to_s

          t1_id = eefps_qrcf.extractions_extraction_forms_projects_sections_type1.present? ? eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1.id.to_s : nil

          t1_type_id = eefps_qrcf.extractions_extraction_forms_projects_sections_type1.present? ? eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1_type.id.to_s : nil

          record_name = eefps_qrcf.records.first.name

          r_hash[efps_id][t1_id] ||= {}
          r_hash[efps_id][t1_id][t1_type_id] ||= {}
          r_hash[efps_id][t1_id][t1_type_id][qrcf_id] ||= {}
          r_hash[efps_id][t1_id][t1_type_id][qrcf_id][record_name] ||= []
          r_hash[efps_id][t1_id][t1_type_id][qrcf_id][record_name] << extraction.id

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


#      #then results sections
#      eefps_res = extraction.extractions_extraction_forms_projects_sections.
#        joins(:extraction_forms_projects_section).
#        where(extraction_forms_projects_sections:
#              {extraction_forms_projects_section_type_id: 3})
#
#      eefps_res.each do |eefps|
#        efps = eefps.extraction_forms_projects_section
#        rssm_hash[efps.id.to_s] ||= {}
#
#        efp
#
#
#        eefps_t1 = eefps.extractions_extraction_forms_projects_sections_type1
#        # lets see if a population is shared
#        populations = eefps_t1.extractions_extraction_forms_projects_sections_type1_rows
#
#        populations.each do |population|
#          # we also want to check if a timepoint is shared
#          population.result_statistic_sections.each do |rss|
#            timepoints = population.extractions_extraction_forms_projects_sections_type1_row_columns
#          end
#
#          case rss.result_statistic_section_type_id
#          # I wonder if theres a  way to do this without writing a separate case for each type
#          when 1
#            #Descriptive Statistics
#            #TpsArmsRssm
#          when 2
#            #Between Arm Comparisons
#            #TpsComparisonsRssm
#          when 3
#            #Within Arm Comparisons
#            #ComparisonsArmsRssm
#          when 4
#            #NET Change
#            #WacsBacsRssm
#          else
#            byebug
#          end
#
#          measures = rss.measures
#
#          rss.comparisons.each do |comparison|
#            comparison.comparate_groups.each do |comparate_group|
#              comparate_group.comparates.each do |comparates|
#
#              end
#            end
#          end
#
#          #timepoints.each do |timepoint|
#          #end
#        end
#      end
    end

    r_hash.each do |efps_id, r_efps_hash|
      r_efps_hash.each do |t1_id, r_efps_t1_hash|
        r_efps_t1_hash.each do |t1_type_id, r_efps_t1_t1t_hash|
          r_efps_t1_t1t_hash.each do |qrcf_id, r_efps_t1_t1t_qrcf_hash|
            r_efps_t1_t1t_qrcf_hash.each do |record_name, r_es|
              if r_es.length == extractions.length
                eefps = self.extractions_extraction_forms_projects_sections.find_or_create_by!(extraction_forms_projects_section_id: efps_id)
                qrcf = QuestionRowColumnField.find(qrcf_id)
                # what if type1 is nil
                t1 = t1_id.present? ? Type1.find(t1_id) : nil
                t1_type = t1_type_id.present? ? Type1Type.find(t1_type_id) : nil
                eefps_t1 = t1.present? ? ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by!(extractions_extraction_forms_projects_section: eefps, type1: t1, type1_type: t1_type) : nil
                #we want  to change find_or_create_by into  find_by asap
                eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by!(extractions_extraction_forms_projects_section: eefps, extractions_extraction_forms_projects_sections_type1: eefps_t1,  question_row_column_field: qrcf)
                record = Record.find_or_create_by!(recordable: eefps_qrcf, recordable_type: eefps_qrcf.class.name, name: record_name.dup.to_s)
                #we want to create eefps_qrcf if its not there
                #we want to
              end
            end
          end
        end
      end
    end

    #create the same type1 in self
    t1_hash.each do |efps_id, t1_efps_hash|
      t1_efps_hash.each do |type1_id, t1_es|
        if t1_es.length == extractions.length
          eefps = self.extractions_extraction_forms_projects_sections.find_or_create_by!(extraction_forms_projects_section_id: efps_id)
          type1 = Type1.find(type1_id)
          eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by!(
            extractions_extraction_forms_projects_section: eefps,
            type1: type1 )

          # population and timepoint creation
          p_hash[efps_id][type1_id].each do |population_name_id, p_es|
            if p_es.length == extractions.length
              population_name = PopulationName.find(population_name_id)
              eefps_t1_row = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by!(
                extractions_extraction_forms_projects_sections_type1: eefps_t1,
                population_name: population_name )

              tp_hash[efps_id][type1_id][population_name_id].each do |timepoint_name_id, t_es|
                if t_es.length == extractions.length
                  timepoint_name = TimepointName.find(timepoint_name_id)
                  ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by!(
                    extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row,
                    is_baseline: false, #should this be true in some cases?
                    timepoint_name: timepoint_name )
                end
              end

              eefps_t1_row.result_statistic_sections.each do |rss|
                rss_type_id = rss.result_statistic_section_type.id.to_s
                c_hash[efps_id][type1_id][population_name_id][rss_type_id].each do |comparison_name, comparison_arr|
                  if comparison_arr.length == extractions.length
                    # get one comparison to clone
                    # is it possible that this comparable exists? what then?
                    master_comp = Comparison.find(comparison_arr.first)
                    clone_comp = Comparison.create!(result_statistic_section: rss)
                    master_comp.comparate_groups.each do |old_comparate_group|
                      new_comparate_group = ComparateGroup.create!(comparison: clone_comp)
                      old_comparate_group.comparates.each do |old_comparate|
                        old_comparable_element = old_comparate.comparable_element
                        old_comparable = old_comparable_element.comparable
                        if old_comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1
                          comp_t1 = old_comparable.type1
                          comp_eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by!(extractions_extraction_forms_projects_section: eefps, type1: comp_t1)
                          new_comparable_element = ComparableElement.create!(comparable: comp_eefps_t1, comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1')
                          new_comparate = Comparate.create!(comparate_group: new_comparate_group, comparable_element: new_comparable_element)
                        elsif old_comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1RowColumn
                          comp_tn = old_comparable.timepoint_name
                          comp_eefps_t1_row_column = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by!(extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row, timepoint_name: comp_tn)
                          new_comparable_element = ComparableElement.create!(comparable: comp_eefps_t1_row_column, comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn')
                          new_comparate = Comparate.create!(comparate_group: new_comparate_group, comparable_element: new_comparable_element)
                        end
                      end
                    end
                    cloned_c_hash[comparison_name] = clone_comp
                  end
                end

                rssm_hash[efps_id][type1_id][population_name_id][rss_type_id].each do |measure_id, extraction_arr|

                  ###check if the count is equal to the count of extraction
                  if extraction_arr.length != extractions.length
                    next
                  end


                  rssm = ResultStatisticSectionsMeasure.find_or_create_by!(result_statistic_section_id: rss.id, measure_id: measure_id)
                  rssm_id = rssm.id.to_s
                  rss.result_statistic_sections_measures << rssm

                  case rss_type_id
                  when "1"
                    #Descriptive Statistics
                    #TpsArmsRssm
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |tp_name_id, three_tp_hash|
                      three_tp_hash.each do |t1_efps_id, three_tp_t1efps_hash|
                        three_tp_t1efps_hash.each do |t1_id, ex_arr|
                          if ex_arr.length == extractions.length
                            begin
                              tp_name = TimepointName.find(tp_name_id)
                              tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by!(extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row, timepoint_name: tp_name)
                              t1_eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by!(extraction: self, extraction_forms_projects_section_id: t1_efps_id)
                              t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by!(extractions_extraction_forms_projects_section: t1_eefps, type1_id: t1_id)
                              tps_arms_rssm = TpsArmsRssm.find_or_create_by!(result_statistic_sections_measure: rssm, timepoint: tp, extractions_extraction_forms_projects_sections_type1: t1)

                              result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][t1_efps_id][t1_id].each do |record_name, record_ex_arr|
                                if record_ex_arr.length == extractions.length
                                  record = Record.find_or_create_by!(name: record_name, recordable: tps_arms_rssm, recordable_type: 'TpsArmsRssm')
                                end
                              end
                            rescue => e
                              byebug
                            end
                          end
                        end
                      end
                    end
                  when "2"
                    #Between Arm Comparisons
                    #TpsComparisonsRssm
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |tp_name_id, three_tp_hash|
                      three_tp_hash.each do |comparison_name, ex_arr|
                        if ex_arr.length == extractions.length
                          tp_name = TimepointName.find(tp_name_id)
                          tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by!(extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row, timepoint_name: tp_name)
                          comparison = cloned_c_hash[comparison_name]
                          tps_comparisons_rssm = TpsComparisonsRssm.find_or_create_by!(result_statistic_sections_measure: rssm, timepoint: tp, comparison: comparison)
                          result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][comparison_name].each do |record_name, record_ex_arr|
                            if record_ex_arr.length == extractions.length
                              record = Record.find_or_create_by!(name: record_name, recordable: tps_comparisons_rssm, recordable_type: 'TpsComparisonsRssm')
                            end
                          end
                        end
                      end
                    end
                  when "3"
                    #Within Arm Comparisons
                    #ComparisonsArmsRssm
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |comparison_name, three_c_hash|
                      three_c_hash.each do |t1_efps_id, three_c_t1efps_hash|
                        three_c_t1efps_hash.each do |t1_id, ex_arr|
                          if ex_arr.length == extractions.length
                            comparison = cloned_c_hash[comparison_name]

                            t1_eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by!(extraction: self, extraction_forms_projects_section_id: t1_efps_id)
                            t1_name = Type1.find(t1_id)
                            t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by!(extractions_extraction_forms_projects_section: t1_eefps, type1: t1_name)

                            comparisons_arms_rssm = ComparisonsArmsRssm.find_or_create_by!(result_statistic_sections_measure: rssm, comparison: comparison, extractions_extraction_forms_projects_sections_type1: t1)
                            result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][t1_efps_id][t1_id].each do |record_name, record_ex_arr|
                              if record_ex_arr.length == extractions.length
                                record = Record.find_or_create_by!(name: record_name, recordable: comparisons_arms_rssm, recordable_type: 'ComparisonsArmsRssm')
                              end
                            end
                          end
                        end
                      end
                    end
                  when "4"
                    #NET Change
                    #WacsBacsRssm
                    three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |wac_name, three_wac_hash|
                      three_wac_hash.each do |bac_name, ex_arr|
                        if ex_arr.length == extractions.length
                          wac = cloned_c_hash[wac_name]
                          bac = cloned_c_hash[bac_name]

                          wacs_bacs_rssm = WacsBacsRssm.find_or_create_by!(result_statistic_sections_measure: rssm, wac: wac, bac: bac)
                          result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name].each do |record_name, record_ex_arr|
                            if record_ex_arr.length == extractions.length
                              record = Record.find_or_create_by!(name: record_name, recordable: wacs_bacs_rssm, recordable_type: 'WacsBacsRssm')
                            end
                          end
                        end
                      end
                    end
                  else
                    byebug
                  end
                end
              end
            end
          end
        end
      end
    end


#    i_hash.each do |efps_id, i_i_hash|
#      i_i_hash.each do |type1_id, i_i_i_hash|
#        i_i_i_hash.each do |population_name_id, i_i_i_i_hash|
#          i_i_i_i_hash.each do |rss_type_id, i_i_i_i_i_hash|
#            i_i_i_i_i_hash.each do |measure_id, i_i_i_i_i_i_hash|
#              i_i_i_i_i_i_hash.each do |thing_1, i_i_i_i_i_i_i_hash|
#                i_i_i_i_i_i_i_hash.each do |thing_2, i_i_i_i_i_i_i_i_hash|
#                  i_i_i_i_i_i_i_i_hash.each do |record_name, ex_arr|
#                    if ex_arr.length == extractions.length
#                      case rss_type_id
#                      when 1
#                        #Descriptive Statistics
#                        #TpsArmsRssm
#                      when 2
#                        #Between Arm Comparisons
#                        #TpsComparisonsRssm
#                      when 3
#                        #Within Arm Comparisons
#                        #ComparisonsArmsRssm
#                      when 4
#                        #NET Change
#                        #WacsBacsRssm
#                      else
#                        byebug
#                      end
#                    end
#                  end
#                end
#              end
#            end
#          end
#        end
#      end
#    end
    # after going through all the extractions, we need to find_or_create_by them in the consolidated one
    # assume all eefps is there. true?

  end
end
