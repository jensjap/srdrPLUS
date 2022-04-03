require 'simple_export_job/sheet_info_module'

# We keep several dictionaries here. They all track the same information such as type1s, populations and timepoints.
# One list is kept as a master list. Those are on SheetInfo.type1s, SheetInfo.populations, and SheetInfo.timepoints.
# Another is kept for each extraction.
class SheetInfo
  extend SheetInfoModule

  attr_reader :header_info, :extractions, :key_question_selections, :type1s, :populations, :timepoints, :question_row_columns, :rssms, :data_header_hash

  def initialize(project = nil)
    @header_info             = ['Extraction ID', 'Consolidated', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID', 'Authors', 'Publication Date', 'Key Questions']
    # @data_header_hash key structure rss_type_id > outcome_type > col_id > rssm
    @data_header_hash        = Hash.new
    @key_question_selections = Array.new
    @extractions             = Hash.new
    @type1s                  = Set.new
    @populations             = Set.new
    @timepoints              = Set.new
    @question_row_columns    = Set.new
    @rssms                   = Set.new
    @project                 = project
  end

  def new_extraction_info(extraction)
    @extractions[extraction.id] = {
      extraction_id: extraction.id,
      type1s:               [],
      populations:          [],
      timepoints:           [],
      question_row_columns: [],
      rss_columns:          {},
      sorted_rssms_2:       {},
      rssms:                [] }
  end

  def set_extraction_info(params)
    @extractions[params[:extraction_id]][:extraction_info] = params
  end

  def add_type1(params)
    @extractions[params[:extraction_id]][:type1s] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    @type1s << dup
  end

  def add_population(params)
    @extractions[params[:extraction_id]][:populations] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    @populations << dup
  end

  def add_timepoint(params)
    @extractions[params[:extraction_id]][:timepoints] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    @timepoints << dup
  end

  def add_question_row_column(params)
    @extractions[params[:extraction_id]][:question_row_columns] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    dup.delete(:eefps_qrfc_values)
    @question_row_columns << dup
  end

  def add_rssm(params)
    # For Ian's special request, we collect rssms per arm/bac comparator as well
    add_rssm_params_for_legacy(params)
    add_rssm_params_for_legacy_2(params)

    # Add full params hash to @extractions[:extraction_id][:rssms] array.
    @extractions[params[:extraction_id]][:rssms] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    dup.delete(:rssm_values)
    @rssms << dup
  end

  def add_rssm_params_for_legacy(params)
    @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]] = {} unless @extractions[params[:extraction_id]][:rss_columns].has_key? params[:result_statistic_section_type_id]
    @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]] = {} unless @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]].has_key? params[:outcome_id]
    @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]][params[:population_id]] = {} unless @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]].has_key? params[:population_id]
    @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]][params[:population_id]][params[:row_id]] = {} unless @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]][params[:population_id]].has_key? params[:row_id]
    @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]][params[:population_id]][params[:row_id]][params[:col_id]] = [] unless @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]][params[:population_id]][params[:row_id]].has_key? params[:col_id]
    @extractions[params[:extraction_id]][:rss_columns][params[:result_statistic_section_type_id]][params[:outcome_id]][params[:population_id]][params[:row_id]][params[:col_id]] << params
  end

  def add_rssm_params_for_legacy_2(params)
    # extraction_id > sorted_rssms_2 > rss_type_id > outcome_type > outcome_id > population_id > row_id > col_id > rssm
    @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]] = {} unless @extractions[params[:extraction_id]][:sorted_rssms_2].has_key? params[:result_statistic_section_type_id]
    @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]] = {} unless @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]].has_key? params[:outcome_type]
    @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]] = {} unless @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]].has_key? params[:outcome_id]
    @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]][params[:population_id]] = {} unless @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]].has_key? params[:population_id]
    @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]][params[:population_id]][params[:row_id]] = {} unless @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]][params[:population_id]].has_key? params[:row_id]
    @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]][params[:population_id]][params[:row_id]][params[:col_id]] = [] unless @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]][params[:population_id]][params[:row_id]].has_key? params[:col_id]
    @extractions[params[:extraction_id]][:sorted_rssms_2][params[:result_statistic_section_type_id]][params[:outcome_type]][params[:outcome_id]][params[:population_id]][params[:row_id]][params[:col_id]] << params
  end

  # Sort rssm into @data_header_hash.
  # @data_header_hash key structure rss_type_id > outcome_type > col_id > rssm
  # Each section has different rss_column mappings:
  # Descriptive Statistics - column = Arms
  # BAC Statistics         - column = BAC Comparisons
  # WAC Statistics         - column = Arms
  # Net Difference         - column = BAC Comparisons
  def find_measures_for_each_section_per_rss_column
    @extractions.each do |extraction_id, v0|
      v0[:sorted_rssms_2].each do |rss_type_id, v1|
        v1.each do |outcome_type, v2|
          v2.each do |outcome_id, v3|
            v3.each do |population_id, v4|
              v4.each do |row_id, v5|
                v5.each do |col_id, rssms|
                  rssms.each do |rssm|
                    @data_header_hash[rss_type_id] = {} unless @data_header_hash.has_key? rss_type_id
                    @data_header_hash[rss_type_id][outcome_type] = {} unless @data_header_hash[rss_type_id].has_key? outcome_type
                    @data_header_hash[rss_type_id][outcome_type][col_id] = [] unless @data_header_hash[rss_type_id][outcome_type].has_key? col_id
                    @data_header_hash[rss_type_id][outcome_type][col_id] << rssm[:measure_name]

                    @data_header_hash[:max_col] = {} unless @data_header_hash.has_key? :max_col
                    @data_header_hash[:max_col][rss_type_id] = {} unless @data_header_hash[:max_col].has_key? rss_type_id
                    @data_header_hash[:max_col][rss_type_id][outcome_type] = {} unless @data_header_hash[:max_col][rss_type_id].has_key? outcome_type
                    @data_header_hash[:max_col][rss_type_id][outcome_type][:max_col] = 0 unless @data_header_hash[:max_col][rss_type_id][outcome_type].has_key?(:max_col)
                    max_col = v5.length
                    @data_header_hash[:max_col][rss_type_id][outcome_type][:max_col] = max_col if (@data_header_hash[:max_col][rss_type_id][outcome_type][:max_col] < max_col)
                  end  # rssms.each do |rssm|
                end  # v5.each do |col_id, rssms|
              end  # v4.each do |row_id, v5|
            end  # v3.each do |population_id, v4|
          end  # v2.each do |outcome_id, v3|
        end  # v1.each do |outcome_type, v2|
      end  # v0[:sorted_rssms_2].each do |rss_type_id, v1|
    end  # @extractions.each do |extraction_id, v0|
  end

  def data_headers(section_id, outcome_type, col_name)
    # Return if this section/outcome_type combination doesn't apply.
    return [] if @data_header_hash.try(:[], section_id).try(:[], outcome_type).nil?

    return_array = []
    cnt_col = @data_header_hash.try(:[], :max_col).try(:[], section_id).try(:[], outcome_type).try(:[], :max_col)
    set_measures = Set.new

    @data_header_hash.try(:[], section_id).try(:[], outcome_type).try(:keys).to_a.each do |key|
      @data_header_hash[section_id][outcome_type][key].each do |measure_name|
        # Since case-insensitive sets are not a thing, we create a new array with all elements downcased and
        # then check against a downcased measures_name, whether to include it or not.
        set_measures << measure_name unless (set_measures.to_a.map(&:downcase).include?(measure_name.downcase))
      end  # @data_header_hash[section_id][outcome_type][key].each do |measure_name|
    end  # @data_header_hash.try(:[], section_id).try(:[], outcome_type).try(:keys).to_a.each do |key|

    cnt_col.times do |i|
      return_array << "#{ col_name } Name #{ i+1 }"

      # Only Descriptive Statistics and WAC Comparison sections deal with Arms as the rss columns, therefore description only applies to them.
      if [1, 3].include? section_id
        return_array << "#{ col_name } Description #{ i+1 }"
      end

      set_measures.each do |m|
        return_array << m
      end
    end

    # Housekeeping for later:
    # Keep track of how many measures there are per section/outcome_type.
    # When section type is 1 or 3 we need to add 2 more to the count because the column groups include Arm Name and Arm Description.
    # Otherwise we only add 1 to the count because the column group will include Comparison Name only.
    if [1, 3].include? section_id
      @data_header_hash.try(:[], :max_col).try(:[], section_id).try(:[], outcome_type)[:no_of_measures] = set_measures.length + 2

    else
      @data_header_hash.try(:[], :max_col).try(:[], section_id).try(:[], outcome_type)[:no_of_measures] = set_measures.length + 1

    end

    return_array
  end

  def populate!(type, kq_ids, efp, efps)
    return populate_sheet_info_with_extractions_results_data(self, kq_ids, efp, efps) if type == :results

    # Every row represents an extraction.
    @project.extractions.each do |extraction|
      # Collect distinct list of questions based off the key questions selected for this extraction.
      kq_ids_by_extraction = SheetInfo.fetch_kq_selection(extraction, kq_ids)

      # Create base for extraction information.
      self.new_extraction_info(extraction)

      if type == :type2
        # Collect distinct list of questions based off the key questions selected for this extraction.
        kq_ids_by_extraction = SheetInfo.fetch_kq_selection(extraction, kq_ids)
        questions = SheetInfo.fetch_questions(@project.id, kq_ids_by_extraction, efps)
      end

      # Collect basic information about the extraction.
      self.set_extraction_info(
        extraction_id: extraction.id,
        consolidated: extraction.consolidated.to_s,
        username: extraction.username,
        citation_id: extraction.citation.id,
        citation_name: extraction.citation.name,
        authors: extraction.citation.authors.collect(&:name).join(', '),
        publication_date: extraction.citation.try(:journal).try(:get_publication_year),
        refman: extraction.citation.refman,
        pmid: extraction.citation.pmid,
        kq_selection: KeyQuestion.where(id: kq_ids_by_extraction).collect(&:name).map(&:strip).join("\x0D\x0A")
      )

      if type == :type1
        eefps = efps.extractions_extraction_forms_projects_sections.find_or_create_by(
          extraction: extraction,
          extraction_forms_projects_section: efps
        )

        # Iterate over each of the type1s that are associated with this particular # extraction's
        # extraction_forms_projects_section and collect type1, population, and timepoint information.
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          self.add_type1(
            extraction_id: extraction.id,
            section_name: efps.section.try(:name).try(:singularize),
            id: eefpst1.type1.id,
            name: eefpst1.type1.name,
            description: eefpst1.type1.description,
            units: eefpst1.units
          )

          eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |pop|
            self.add_population(
              extraction_id: extraction.id,
              id: pop.population_name.id,
              name: pop.population_name.name,
              description: pop.population_name.description
            )

            pop.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
              self.add_timepoint(
                extraction_id: extraction.id,
                id: tp.timepoint_name.id,
                name: tp.timepoint_name.name,
                unit: tp.timepoint_name.unit
              )
            end  # pop.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
          end  # eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |pop|
        end  # eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|

      elsif type == :type2
        eefps = efps.extractions_extraction_forms_projects_sections.find_or_create_by!(
          extraction: extraction,
          link_to_type1: efps.link_to_type1.nil? ?
            nil :
            ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
              extraction: extraction,
              extraction_forms_projects_section: efps.link_to_type1
            )
        )

        # If this section is linked we have to iterate through each occurrence of
        # type1 via eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.
        # Otherwise we proceed with eefpst1s set to a custom Struct that responds
        # to :id, type1: :id.
        eefpst1s = (eefps.extraction_forms_projects_section.try(:extraction_forms_projects_section_option).try(:by_type1) &&
          eefps.link_to_type1.present?) ?
            eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s :
            [Struct.new(:id, :type1).new(nil, Struct.new(:id, :name, :description).new(nil))]

        eefpst1s.each do |eefpst1|
          questions.each do |q|
            q.question_rows.each do |qr|
              qr.question_row_columns.each do |qrc|
                self.add_question_row_column(
                  extraction_id: extraction.id,
                  section_name: efps.section.name.try(:singularize),
                  eefpst1_id: eefpst1.id,
                  type1_id: eefpst1.type1.id,
                  type1_name: eefpst1.type1.name,
                  type1_description: eefpst1.type1.description,
                  question_id: q.id,
                  question_name: q.name,
                  question_description: q.description,
                  question_row_id: qr.id,
                  question_row_name: qr.name,
                  question_row_column_id: qrc.id,
                  question_row_column_name: qrc.name,
                  question_row_column_options: qrc
                    .question_row_columns_question_row_column_options
                    .where(question_row_column_option_id: 1)
                    .pluck(:id, :name),
                  eefps_qrfc_values: eefps.eefps_qrfc_values(eefpst1.id, qrc))
              end  # qr.question_row_columns.each do |qrc|
            end  # q.question_rows.each do |qr|
          end  # questions.each do |q|
        end  # eefps.type1s.each do |eefpst1|
      end
    end  # END @project.extractions.each do |extraction|
  end

  def populate_sheet_info_with_extractions_results_data(sheet_info, kq_ids, efp, efps)
    @project.extractions.each do |extraction|
      # Collect distinct list of questions based off the key questions selected for this extraction.
      kq_ids_by_extraction = SheetInfo.fetch_kq_selection(extraction, kq_ids)

      #!!! We can probably use scope for this.
      # Find all eefps that are Outcomes.
      efps_outcomes = efp.extraction_forms_projects_sections
        .joins(:section)
        .where(sections: { name: 'Outcomes' })
      eefps_outcomes = ExtractionsExtractionFormsProjectsSection.where(
        extraction: extraction,
        extraction_forms_projects_section: efps_outcomes)

      # Find all eefps that are Arms.
      efps_arms = efp.extraction_forms_projects_sections
        .joins(:section)
        .where(sections: { name: 'Arms' })
      eefps_arms = ExtractionsExtractionFormsProjectsSection.
        includes({
          extractions_extraction_forms_projects_sections_type1s: [
            :type1,
            {
              extractions_extraction_forms_projects_sections_type1_rows: [
                :population_name,
                {
                  result_statistic_sections: [
                    :result_statistic_section_type,
                    :comparisons,
                    { result_statistic_sections_measures: :measure }
                  ],
                  extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name
                },
              ]
            }
          ]
        }).
        where(extraction: extraction, extraction_forms_projects_section: efps_arms)

      # Create base for extraction information.
      sheet_info.new_extraction_info(extraction)

      # Collect basic information about the extraction.
      sheet_info.set_extraction_info(
        extraction_id: extraction.id,
        consolidated: extraction.consolidated.to_s,
        username: extraction.username,
        citation_id: extraction.citation.id,
        citation_name: extraction.citation.name,
        authors: extraction.citation.authors.collect(&:name).join(', '),
        publication_date: extraction.citation.try(:journal).try(:get_publication_year),
        refman: extraction.citation.refman,
        pmid: extraction.citation.pmid,
        kq_selection: KeyQuestion.where(id: kq_ids_by_extraction).collect(&:name).map(&:strip).join("\x0D\x0A"))

      eefps = efps.extractions_extraction_forms_projects_sections.find_by(
        extraction: extraction,
        extraction_forms_projects_section: efps)

      # Each Outcome has multiple Populations, which in turn has 4 result
      # statistic quadrants . We iterate over each of the results statistic
      # quadrants:
      #   - (q1) Descriptive (DSC)
      #   - (q2) Between Arm Comparison (BAC)
      #   - (q3) Within Arm Comparison (WAC)
      #   - (q4) Net Change (NET)
      # Each quadrant has rows and columns and within each row/column cell
      # there's a list of measures.
      #
      # Total number of columns in export =
      #   Outcomes x
      #   Populations x
      #   ( (Timepoints x Arms x q1-Measures) +
      #     (Timepoints x BAC  x q2-Measures) +
      #     (   WAC     x Arms x q3-Measures) +
      #     (   WAC     x BAC  x q4-Measures) )
      #
      # To uniquely identify a data value we therefore need:
      # OutcomeID, PopulationID, RowID, ColumnID, MeasureID
      eefps_outcomes.each do |eefps_outcome|
        eefps_outcome.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_outcome|  # Outcome.
          eefpst1_outcome.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|  # Population
            eefpst1r.result_statistic_sections.each do |result_statistic_section|  # Result Statistic Section Quadrant

              case result_statistic_section.result_statistic_section_type_id
              when 1  # Descriptive Statistics - Timepoint x Arm x q1-Measure.
                eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint
                  eefps_arms.each do |eefps_arm|  # Arm
                    eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                      result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q1-Measure

                        sheet_info.add_rssm(
                          extraction_id: extraction.id,
                          section_name: efps.section.name.singularize,
                          outcome_id: eefpst1_outcome.type1.id,
                          outcome_name: eefpst1_outcome.type1.name,
                          outcome_description: eefpst1_outcome.type1.description,
                          outcome_type: eefpst1_outcome.try(:type1_type).try(:name),
                          population_id: eefpst1r.population_name.id,
                          population_name: eefpst1r.population_name.name,
                          population_description: eefpst1r.population_name.description,
                          result_statistic_section_type_id: result_statistic_section.result_statistic_section_type.id,
                          result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                          row_id: eefpst1rc.timepoint_name.id,             # timepoint_id       Note: Changing this to row and col so we
                          row_name: eefpst1rc.timepoint_name.name,         # timepoint_name            can use the same names later.
                          row_unit: eefpst1rc.timepoint_name.unit,         # timepoint_unit
                          col_id: eefpst1_arm.type1.id,                    # arm_id
                          col_name: eefpst1_arm.type1.name,                # arm_name
                          col_description: eefpst1_arm.type1.description,  # arm_description
                          measure_id: rssm.measure.id,
                          measure_name: rssm.measure.name,
                          rssm_values: eefpst1_arm.tps_arms_rssms_values(eefpst1rc.id, rssm))

                      end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q1-Measure
                    end  # eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                  end  # eefps_arms.each do |eefps_arm|
                end  # eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint

              when 2  # Between Arm Comparisons - Timepoint x BAC x q2-Measure.
                eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint
                  result_statistic_section.comparisons.each do |bac|
                    result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q2-Measure

                      sheet_info.add_rssm(
                        extraction_id: extraction.id,
                        section_name: efps.section.name.singularize,
                        outcome_id: eefpst1_outcome.type1.id,
                        outcome_name: eefpst1_outcome.type1.name,
                        outcome_description: eefpst1_outcome.type1.description,
                        outcome_type: eefpst1_outcome.try(:type1_type).try(:name),
                        population_id: eefpst1r.population_name.id,
                        population_name: eefpst1r.population_name.name,
                        population_description: eefpst1r.population_name.description,
                        result_statistic_section_type_id: result_statistic_section.result_statistic_section_type.id,
                        result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                        row_id: eefpst1rc.timepoint_name.id,      # timepoint_id
                        row_name: eefpst1rc.timepoint_name.name,  # timepoint_name
                        row_unit: eefpst1rc.timepoint_name.unit,  # timepoint_unit
                        col_id: bac.id,                           # comparison_id
                        col_name: bac.pretty_print_export_header, # comparison name
                        measure_id: rssm.measure.id,
                        measure_name: rssm.measure.name,
                        rssm_values: bac.tps_comparisons_rssms_values(eefpst1rc.id, rssm))

                    end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q2-Measure
                  end  # result_statistic_section.comparisons.each do |bac|
                end  # eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint

              when 3  # Within Arm Comparisons - WAC x Arm x q3-Measure.
                result_statistic_section.comparisons.each do |wac|
                  eefps_arms.each do |eefps_arm|  # Arm
                    eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                      result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q3-Measure

                        sheet_info.add_rssm(
                          extraction_id: extraction.id,
                          section_name: efps.section.name.singularize,
                          outcome_id: eefpst1_outcome.type1.id,
                          outcome_name: eefpst1_outcome.type1.name,
                          outcome_description: eefpst1_outcome.type1.description,
                          outcome_type: eefpst1_outcome.try(:type1_type).try(:name),
                          population_id: eefpst1r.population_name.id,
                          population_name: eefpst1r.population_name.name,
                          population_description: eefpst1r.population_name.description,
                          result_statistic_section_type_id: result_statistic_section.result_statistic_section_type.id,
                          result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                          row_id: wac.id,                                 # wac_id
                          row_name: wac.pretty_print_export_header,       # comparison name
                          col_id: eefpst1_arm.type1.id,                   # arm_id
                          col_name: eefpst1_arm.type1.name,               # arm_name
                          col_description: eefpst1_arm.type1.description, # arm_description
                          measure_id: rssm.measure.id,
                          measure_name: rssm.measure.name,
                          rssm_values: wac.comparisons_arms_rssms_values(eefpst1_arm.id, rssm))

                      end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q3-Measure
                    end  # eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                  end  # eefps_arms.each do |eefps_arm|  # Arm
                end  # result_statistic_section.comparisons.each do |wac|

              when 4  # Net Change - WAC x BAC x q4-Measure.
                bac_section = result_statistic_section.population.between_arm_comparisons_section
                wac_section = result_statistic_section.population.within_arm_comparisons_section
                bac_section.comparisons.each do |bac|
                  wac_section.comparisons.each do |wac|
                    result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q4-Measure

                      sheet_info.add_rssm(
                        extraction_id: extraction.id,
                        section_name: efps.section.name.singularize,
                        outcome_id: eefpst1_outcome.type1.id,
                        outcome_name: eefpst1_outcome.type1.name,
                        outcome_description: eefpst1_outcome.type1.description,
                        outcome_type: eefpst1_outcome.try(:type1_type).try(:name),
                        population_id: eefpst1r.population_name.id,
                        population_name: eefpst1r.population_name.name,
                        population_description: eefpst1r.population_name.description,
                        result_statistic_section_type_id: result_statistic_section.result_statistic_section_type.id,
                        result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                        row_id: wac.id,                            # wac_id
                        row_name: wac.pretty_print_export_header,  # wac comparison name
                        col_id: bac.id,                            # bac_id
                        col_name: bac.pretty_print_export_header,  # bac comparison name
                        measure_id: rssm.measure.id,
                        measure_name: rssm.measure.name,
                        rssm_values: wac.wacs_bacs_rssms_values(bac.id, rssm))

                    end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q4-Measure
                  end  # wac_section.comparisons.each do |wac|
                end  # bac_section.comparisons.each do |bac|
              end  # case result_statistic_section.result_statistic_section_type_id
            end  # eefpst1r.result_statistic_sections.each do |result_statistic_section|  # Result Statistic Section Quadrant
          end  # eefpst1_outcome.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|  # Population
        end  # eefps_outcome.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_outcome|  # Outcome.
      end  # eefps_outcomes.each do |eefps_outcome|
    end  # @project.extractions.each do |extraction|

    # Used to populate data headers in the results statistics sections
    # These have the form ['Arm Name 1', 'Arm Description 1', 'Measure 1', 'Measure 2', 'Arm Name 2', ...]
    sheet_info.find_measures_for_each_section_per_rss_column
  end
end
