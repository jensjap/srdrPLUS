class ResultStatisticSectionsMeasureRepairService
  def self.repair!
    query = "
SELECT
    rss.id
FROM
    `result_statistic_sections` rss
        JOIN
    `extractions_extraction_forms_projects_sections_type1_rows` eefpst1r ON eefpst1r.id = rss.population_id
        JOIN
    `extractions_extraction_forms_projects_sections_type1s` eefpst1 ON eefpst1.id = eefpst1r.extractions_extraction_forms_projects_sections_type1_id
        JOIN
    `extractions_extraction_forms_projects_sections` eefps ON eefps.id = eefpst1.extractions_extraction_forms_projects_section_id
        JOIN
    `extractions` e ON e.id = eefps.extraction_id
        JOIN
    `projects` p ON p.id = e.project_id
WHERE
    p.id = 25
"
    results = ActiveRecord::Base.connection.exec_query(query)
    results.each do |result|
      rss_id = result["id"]
      rss = ResultStatisticSection.find(rss_id)

      ResultStatisticSectionTypesMeasure.where(
        result_statistic_section_type: rss.result_statistic_section_type,
        type1_type: rss.population.extractions_extraction_forms_projects_sections_type1.type1_type,
        default: true
      ).each do |rsstm|
        rss.result_statistic_sections_measures.find_or_create_by!(measure: rsstm.measure)
      end
    end
  end
end
