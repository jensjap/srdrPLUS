class ProjectService
  def self.status_report(project_id)
    project = Project.includes(:extractions).find(project_id)
    citations_project_kpis = JSON.parse(ActionController::Base.render(
                                          template: 'abstract_screenings/kpis',
                                          assigns: { project: }
                                        ))
    extractions = project.extractions
    count = extractions.count
    between_0_and_1_weeks =
      extractions.select do |extraction|
        extraction.approved_on.present? &&
          (extraction.approved_on - extraction.created_at).between?(0.weeks, 1.weeks - 1)
      end.count
    between_1_and_2_weeks =
      extractions.select do |extraction|
        extraction.approved_on.present? &&
          (extraction.approved_on - extraction.created_at).between?(1.weeks, 2.weeks - 1)
      end.count
    between_2_and_3_weeks =
      extractions.select do |extraction|
        extraction.approved_on.present? &&
          (extraction.approved_on - extraction.created_at).between?(2.weeks, 3.weeks - 1)
      end.count
    three_weeks_or_more =
      extractions.select do |extraction|
        extraction.approved_on.nil? ||
          (extraction.approved_on - extraction.created_at) >= 3.weeks
      end.count
    extraction_kpis = {
      between_0_and_1_weeks:,
      between_1_and_2_weeks:,
      between_2_and_3_weeks:,
      three_weeks_or_more:,
      count:
    }

    {
      extraction_kpis:,
      citations_project_kpis:
    }
  end
end
