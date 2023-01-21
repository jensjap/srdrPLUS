class ConsolidationService
  def self.efps_sections(project)
    ExtractionFormsProject.find_by(project:).extraction_forms_projects_sections.includes(:section).map do |efps|
      {
        efps_id: efps.id,
        name: efps.section.name
      }
    end
  end

  def self.efps(efps, citations_project)
    # error possiblities #
    # 1. link_to_type_1s may not mirror exactly between efps and eefps
    # 2. an efps may belong to efpst type 2 but have a link to another efps
    # 3. what if point 2 happens to an eefps i.e. a efps of type1 but with an eefps with a linked eefps
    # questions #
    # 1. how to determine order among eefps type1s and populate their records in a hash while keeping that order

    mh = {
      efps: {},
      eefps: {},
      questions: [],
      current_citations_project: {}
    }
    extractions_lookup = {}
    project = citations_project.project

    extractions = Extraction.includes(projects_users_role: { projects_user: :user }).where(citations_project:).where.not(consolidated: true)
    extractions.each do |extraction|
      extractions_lookup[extraction.id] = extraction.user.email.split('@').first
    end
    efpss = ExtractionFormsProject.find_by(project:).extraction_forms_projects_sections.includes(:section)

    efpss.map do |iefps|
      efpso = iefps.extraction_forms_projects_section_option
      efpso = { by_type1: efpso.by_type1, include_total: efpso.include_total }
      mh[:efps][iefps.id] = {
        data_type: 'efps',
        section_id: iefps.section_id,
        section_name: iefps.section.name,
        efpst_id: iefps.extraction_forms_projects_section_type_id,
        parent_efps_id: iefps.link_to_type1&.id,
        children_efps_ids: iefps.extraction_forms_projects_section_type2s.map(&:id),
        efpso:
      }
    end

    eefpss = ExtractionsExtractionFormsProjectsSection
             .where(extraction: extractions, extraction_forms_projects_section: efpss)
             .uniq { |ieefpss| [ieefpss.extraction_id, ieefpss.extraction_forms_projects_section_id] }
    current_section_eefpss = eefpss.select { |eefps| eefps.extraction_forms_projects_section_id == efps.id }
    section_eefpst1s = []
    eefpss.each do |eefps|
      extraction = eefps.extraction
      parent_eefps_id = eefps.link_to_type1&.id
      efps_id = eefps.extraction_forms_projects_section_id
      section_id = mh[:efps][efps_id][:section_id]
      section_name = mh[:efps][efps_id][:section_name]
      efpso = mh[:efps][efps_id][:efpso]
      linked_section = eefpss.find { |cached_eefpss| cached_eefpss.id == parent_eefps_id }

      by_type1 = efpso[:by_type1]
      include_total = efpso[:include_total]
      type1s =
        if linked_section.nil?
          []
        elsif by_type1 && include_total && linked_section.eefpst1s_without_total.count > 1
          linked_section.eefpst1s_with_total
        elsif by_type1 && !include_total
          linked_section.eefpst1s_without_total
        elsif !by_type1 && include_total
          linked_section.eefpst1s_only_total
        else
          []
        end.map do |eefpst1|
          { extractions_extraction_forms_projects_sections_type1_id: eefpst1.id,
            extractions_extraction_forms_projects_section_id: eefpst1.extractions_extraction_forms_projects_section_id,
            type1_id: eefpst1.type1.id,
            name: eefpst1.type1.name,
            description: eefpst1.type1.description }
        end
      type1s.each do |type1|
        next unless efps_id == efps.id && section_eefpst1s.all? do |section_eefpst1|
                      section_eefpst1[:type1_id] != type1[:type1_id]
                    end

        section_eefpst1s << type1
      end

      mh[:eefps][eefps.id] = {
        data_type: 'eefps',
        extraction_id: extraction.id,
        section_id:,
        section_name:,
        efps_id:,
        type_id: mh[:efps][eefps.extraction_forms_projects_section_id][:efpst_id],
        parent_eefps_id:,
        children_eefps_ids: eefps.link_to_type2s.map(&:id),
        type1s:,
        efpso:
      }
    end

    qrcfs = []

    efps.questions.each do |question|
      question_hash = {
        question_id: question.id,
        name: question.name,
        description: question.description,
        rows: []
      }

      mh[:questions] << question_hash
      question.question_rows.each do |question_row|
        question_row_hash = {
          question_row_id: question_row.id,
          name: question_row.name,
          columns: []
        }
        question_hash[:rows] << question_row_hash
        question_row.question_row_columns.each do |question_row_column|
          qrcf = question_row_column.question_row_column_fields.first
          qrcfs << qrcf
          type_name = question_row_column.question_row_column_type.name
          selection_options = question_row_column.question_row_columns_question_row_column_options.select do |qrcqrco|
            if QuestionRowColumnType::MULTI_SELECTION_TYPES.include?(type_name)
              qrcqrco.question_row_column_option_id == 1
            elsif QuestionRowColumnType::TEXT
              [2, 3].include?(qrcqrco.question_row_column_option_id)
            elsif QuestionRowColumnType::NUMERIC
              [4, 5, 6].include?(qrcqrco.question_row_column_option_id)
            else
              false
            end
          end

          question_row_column_hash = {
            question_row_column_id: question_row_column.id,
            question_row_column_name: question_row_column.name,
            type_name:,
            selection_options:,
            qrcf:
          }
          question_row_hash[:columns] << question_row_column_hash
        end
      end
    end

    all_section_eefpst1_ids = section_eefpst1s.map do |all_section_eefpst1|
      all_section_eefpst1[:extractions_extraction_forms_projects_sections_type1_id]
    end

    # ensures eefpsqrcf exist
    current_section_eefpss.each do |current_section_eefps|
      qrcfs.each do |qrcf|
        if section_eefpst1s.empty?
          ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by(
            extractions_extraction_forms_projects_section: current_section_eefps,
            question_row_column_field: qrcf
          )
        else
          section_eefpst1s.each do |all_section_eefpst1|
            unless current_section_eefps.id == all_section_eefpst1[:extractions_extraction_forms_projects_section_id]
              next
            end

            ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by(
              extractions_extraction_forms_projects_section: current_section_eefps,
              question_row_column_field: qrcf,
              extractions_extraction_forms_projects_sections_type1_id: all_section_eefpst1[:extractions_extraction_forms_projects_sections_type1_id]
            )
          end
        end
      end
    end

    eefpsqrcfs = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.where(
      extractions_extraction_forms_projects_section: current_section_eefpss,
      question_row_column_field: qrcfs
    )

    unless all_section_eefpst1_ids.empty?
      eefpsqrcfs = eefpsqrcfs.where(extractions_extraction_forms_projects_sections_type1_id: all_section_eefpst1_ids)
    end

    # ensures records exist
    eefpsqrcfs.each do |eefpsqrcf|
      Record.find_or_create_by(recordable: eefpsqrcf)
    end

    cell_lookups = {}
    Record.where(recordable: eefpsqrcfs).each do |record|
      begin
        name = JSON.parse(record.name)
      rescue JSON::ParserError, TypeError
        name = record.name
      end
      eefpsqrcf = record.recordable
      eefpst1_id = eefpsqrcf.extractions_extraction_forms_projects_sections_type1_id
      eefps_id = eefpsqrcf.extractions_extraction_forms_projects_section_id
      qrcf_id = eefpsqrcf.question_row_column_field_id
      if name.instance_of?(Array)
        name.each do |id|
          cell_lookups["#{qrcf_id}-#{eefps_id}-#{eefpst1_id}-#{id}"] = true
        end
      else
        cell_lookups["#{qrcf_id}-#{eefps_id}-#{eefpst1_id}"] = name
      end
    end

    citation = citations_project.citation
    mh[:current_citations_project] = {
      project_id: project.id,
      citation_id: citation.id,
      citations_project_id: citations_project.id,
      efps_id: efps.id,
      efpst_id: efps.extraction_forms_projects_section_type_id,
      section_name: efps.section.name,
      section_eefpst1s:,
      current_section_eefpss:,
      by_arms:
        efps.link_to_type1.present? &&
        (mh[:efps][efps.id][:efpso][:by_type1] || mh[:efps][efps.id][:efpso][:include_total]).present?,
      cell_lookups:,
      extractions_lookup:
    }
    mh
  end

  def self.project_citations_grouping_hash(project)
    citations_grouping_hash = {}
    citations_projects = project.citations_projects
    extractions =
      project
      .extractions
      .includes(
        :extraction_checksum,
        statusing: :status,
        citations_project: { citation: { authors_citations: %i[
          author ordering
        ] } }
      )
    citations_projects.each do |citations_project|
      citations_grouping_hash[citations_project.id] = {
        extractions: [],
        consolidated_extraction: nil,
        citation_title: "#{citations_project.citation.author_map_string}: #{citations_project.citation.name}",
        reference_checksum: nil,
        differences: false,
        consolidated_extraction_status: nil
      }
    end

    extractions.each do |extraction|
      if extraction.consolidated
        citations_grouping_hash[extraction.citations_project_id][:consolidated_extraction] = extraction
        citations_grouping_hash[extraction.citations_project_id][:consolidated_extraction_status] =
          extraction.status.name
      else
        citations_grouping_hash[extraction.citations_project_id][:extractions] << extraction
        checksum = extraction.extraction_checksum
        checksum.update_hexdigest if checksum.is_stale
        citations_grouping_hash[extraction.citations_project_id][:reference_checksum] ||= checksum.hexdigest
        if citations_grouping_hash[extraction.citations_project_id][:reference_checksum] != checksum.hexdigest
          citations_grouping_hash[extraction.citations_project_id][:differences] = true
        end
      end
    end
    citations_grouping_hash
  end
end
