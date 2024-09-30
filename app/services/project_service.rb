class ProjectService
  def self.status_report(project, user_id = nil)
    logs = get_logs(project, user_id)
    {
      extraction_activities: extraction_activities(logs),
      extraction_kpis: extraction_kpis(project, user_id),
      logs:,
      projects_users: project.projects_users.includes(user: :profile).map { |pu| { id: pu.user_id, handle: pu.user.handle } }
    }
  end

  def self.get_logs(project, user_id)
    logs = Log.includes({ extraction: { citations_project: :project, user: :profile },
                          user: :profile }).where(extraction: { project: })
    logs = logs.where(extraction: { user_id: }) if user_id
    logs
  end

  def self.extraction_activities(logs)
    activities = []
    %w[awaiting_work awaiting_review work_accepted work_rejected].each do |log_type|
      relevant_logs = logs.select { |log| log.description.include?(log_type) }
      data = 4.downto(0).map do |i|
        reference_time = (Time.now - i.weeks)
        head = reference_time.beginning_of_week
        tail = reference_time.end_of_week
        relevant_logs.select { |log| log.created_at.between?(head, tail) }.count
      end
      activities << {
        name: log_type,
        type: 'bar',
        stack: 'log',
        data:
      }
    end
    activities
  end

  def self.extraction_kpis(project, user_id)
    extractions = project.extractions
    extractions = extractions.where(user_id:) if user_id
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

    [
      { name: 'between_0_and_1_weeks', value: between_0_and_1_weeks },
      { name: 'between_1_and_2_weeks', value: between_1_and_2_weeks },
      { name: 'between_2_and_3_weeks', value: between_2_and_3_weeks },
      { name: 'three_weeks_or_more', value: three_weeks_or_more }
    ]
  end
end
