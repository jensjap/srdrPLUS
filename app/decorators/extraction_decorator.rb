class ExtractionDecorator < Decorator
  def pmid
    citation.pmid.to_s
  end

  def year
    citation.year.to_s
  end

  def name
    citation.name.to_s.truncate(70)
  end

  def authors
    citation.authors.to_s
  end

  def citation_handle
    authors + ', ' + year + ', ' + pmid + '<br />' + name
  end

  def relevant_eefps
    return @relevant_eefps if @relevant_eefps

    efps_ids = project.extraction_forms_projects.first.extraction_forms_projects_sections.map(&:id)
    @relevant_eefps = []
    extractions_extraction_forms_projects_sections.each do |eefps|
      not_duplicate = relevant_eefps.none? do |relevant_eefp|
        relevant_eefp.extraction_forms_projects_section_id == eefps.extraction_forms_projects_section_id
      end
      relevant = efps_ids.include?(eefps.extraction_forms_projects_section_id)
      @relevant_eefps << eefps if relevant && not_duplicate
    end
    @relevant_eefps
  end

  def eefps_count
    @eefps_count ||= relevant_eefps.length
  end

  def progress_meter_width
    @progress_meter_width ||=
      (relevant_eefps.inject(0) do |sum, eefps|
         sum + (eefps.status.name == 'Completed' ? 100.0 : 0)
       end / (eefps_count.zero? ? 1 : eefps_count)).round.to_s
  end

  def tooltip_text
    if relevant_eefps.any? { |eefps| eefps.status.name != 'Completed' }
      "<span style='font-weight: bold;'>Incomplete Sections:</span><br>" +
        (relevant_eefps.map do |eefps|
           eefps.status.name != 'Completed' ? eefps.section.name : ''
         end - ['']).join('<br>')
    else
      "<span style='font-weight: bold;'>Complete!</span>"
    end
  end

  def user_handle
    user&.handle
  end

  def selected_key_questions_positions_and_names
    @selected_key_questions_positions_and_names ||= begin
      selected_kqps = extractions_key_questions_projects_selections.map(&:key_questions_project)
      project_kqps = project.key_questions_projects
      kqp_positions = project_kqps.each_with_index.map { |kqp, index| [kqp.id, index + 1] }.to_h

      selected_kqps.map do |kqp|
        position = kqp_positions[kqp.id]
        name = kqp.key_question.name
        { position: position, name: name }
      end
    end
  end

end
