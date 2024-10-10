class ProjectService
  def self.status_report(project, user_id = nil)
    logs = get_logs(project, user_id)
    {
      extraction_activities: extraction_activities(project, user_id),
      extraction_kpis: extraction_kpis(project, user_id),
      logs:,
      projects_users: project.projects_users.includes(user: :profile).map do |pu|
                        { id: pu.user_id, handle: pu.user.handle }
                      end
    }
  end

  def self.get_logs(project, user_id)
    logs = Log.includes({ extraction: { citations_project: %i[project citation], user: :profile },
                          user: :profile }).where(extraction: { project: }).order(created_at: :desc)
    logs = logs.where(extraction: { user_id: }) if user_id
    logs
  end

  def self.extraction_activities(project, user_id)
    extractions = project.extractions.includes(:logs, citations_project: %i[project citation],
                                                      user: :profile)
    extractions = extractions.where(user_id:) if user_id
    activities = []
    [
      %w[awaiting_work #edcc5f],
      %w[awaiting_review #606fc4],
      %w[work_accepted #a1c876],
      %w[work_rejected #d6776a]
    ].each do |log_type, color|
      relevant_logs = extractions.map do |extraction|
        extraction.logs.select do |log|
          log.description == extraction.status && extraction.status == log_type
        end.min_by(&:id)
      end.compact
      data = 3.downto(0).map do |i|
        head = (i + 1).weeks.ago
        tail = i.weeks.ago
        if i == 3
          relevant_logs.select { |log| log.created_at < tail }.count
        else
          relevant_logs.select { |log| log.created_at.between?(head, tail) }.count
        end
      end
      activities << {
        name: log_type,
        type: 'bar',
        stack: 'log',
        data:,
        itemStyle: {
          color:
        }
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
