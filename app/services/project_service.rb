include ActionView::Helpers::DateHelper
class ProjectService
  def self.status_report(project, user_id = nil)
    {
      extraction_activities: extraction_activities(project, user_id),
      extraction_kpis: extraction_kpis(project, user_id),
      projects_users: project.projects_users.includes(user: :profile).map do |pu|
                        { id: pu.user_id, handle: pu.user.handle }
                      end,
      pending_work: pending_work(project, user_id)
    }
  end

  def self.pending_work(project, user_id)
    extractions = Extraction
                  .where(project:)
                  .where.not(status: 'work_accepted')
                  .includes(:logs, citations_project: :citation, user: :profile)
    extractions = extractions.where(user_id:) if user_id
    extractions.map do |extraction|
      log = extraction.logs.select do |l|
        l.description == extraction.status
      end.min_by(&:created_at)
      {
        handle: extraction&.user&.handle,
        status: extraction.status,
        created_at: log&.created_at,
        time_ago_in_words: log&.created_at ? time_ago_in_words(log&.created_at) : '',
        id: extraction.id,
        title: extraction.citations_project&.citation&.name || 'Unknown Citation'
      }
    end.sort_by { |pending_work| pending_work[:created_at] || 999_999_999 }
  end

  def self.get_logs(project, user_id)
    logs = Log.includes({ extraction: {
                            citations_project: %i[project citation], user: :profile
                          },
                          user: :profile })
              .where(extraction: { project: })
              .order(created_at: :desc)
    logs = logs.where(extraction: { user_id: }) if user_id
    logs
  end

  def self.extraction_activities(project, user_id)
    extractions = project.extractions.includes(:logs, citations_project: %i[project citation],
                                                      user: :profile)
    extractions = extractions.where(user_id:) if user_id
    activities = []
    [
      %w[awaiting_work #dd631b],
      %w[awaiting_review #2a40ae],
      %w[work_returned #8f2a1f],
      %w[work_accepted #347e3d]
    ].each do |log_type, color|
      relevant_logs = extractions.map do |extraction|
        extraction.logs.select do |log|
          log.description == extraction.status && extraction.status == log_type
        end.min_by(&:created_at)
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
        (extraction.approved_on.nil? && (Time.now - extraction.created_at) >= 3.weeks) ||
          (extraction.approved_on && ((extraction.approved_on - extraction.created_at) >= 3.weeks))
      end.count

    [
      { name: 'between_0_and_1_weeks', value: between_0_and_1_weeks },
      { name: 'between_1_and_2_weeks', value: between_1_and_2_weeks },
      { name: 'between_2_and_3_weeks', value: between_2_and_3_weeks },
      { name: 'three_weeks_or_more', value: three_weeks_or_more }
    ]
  end
end
