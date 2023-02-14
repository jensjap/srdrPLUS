class ExtractionDecorator < Decorator
  def pmid
    citation.pmid.to_s
  end

  def year
    citation.year
  end

  def name
    citation.name.to_s.truncate(70)
  end

  def citation_handle
    citation.authors + ', ' + year + ', ' + pmid + '<br />' + name
  end

  def eefps_count
    @eefps_count ||= extractions_extraction_forms_projects_sections.length
  end

  def progress_meter_width
    @progress_meter_width ||= (extractions_extraction_forms_projects_sections.inject(0) do |sum, eefps|
                                 sum + (eefps.status.name == 'Completed' ? 100.0 : 0)
                               end / (eefps_count.zero? ? 1 : eefps_count)).round.to_s
  end

  def tooltip_text
    if extractions_extraction_forms_projects_sections.any? { |eefps| eefps.status.name != 'Completed' }
      "<span style='font-weight: bold;'>Incomplete Sections:</span><br>" +
        (extractions_extraction_forms_projects_sections.map do |eefps|
           eefps.status.name != 'Completed' ? eefps.section.name : ''
         end - ['']).join('<br>')
    else
      "<span style='font-weight: bold;'>Complete!</span>"
    end
  end

  def user_handle
    user.handle
  end
end
