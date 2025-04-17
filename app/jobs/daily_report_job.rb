class DailyReportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    consolidated = {}
    message_report.each do |user, recent_help_key|
      consolidated[user] ||= {
        screening_status_report: [],
        message_report: {},
        extraction_report: []
      }
      consolidated[user][:message_report] = recent_help_key
    end
    screening_status_report.each do |user, screening_status|
      consolidated[user] ||= {
        screening_status_report: [],
        message_report: {},
        extraction_report: []
      }
      consolidated[user][:screening_status_report] += screening_status
    end
    extraction_report.each do |user, log_messages|
      consolidated[user] ||= {
        screening_status_report: [],
        message_report: {},
        extraction_report: []
      }
      consolidated[user][:extraction_report] += log_messages
    end

    consolidated.each do |user, consolidated_hash|
      DailyReportMailer.daily_report(user.email, consolidated_hash).deliver_now
    end
  end

  def message_report
    user_messages = {}
    messages_lookup = {}
    Message
      .includes(user: :profile)
      .where.not(help_key: nil)
      .where(created_at: 1445.minutes.ago..5.minutes.from_now)
      .each do |message|
      message.handle
      messages_lookup[message.help_key] ||= []
      messages_lookup[message.help_key] << message
    end
    recent_help_keys = Message
                       .where.not(help_key: nil)
                       .where(created_at: 1445.minutes.ago..5.minutes.from_now)
                       .select(:help_key)
                       .distinct(:help_key)
                       .pluck(:help_key)

    recent_help_keys.each do |recent_help_key|
      User
        .select(:id, :email)
        .joins(:messages, :profile)
        .where(messages: { help_key: recent_help_key })
        .each do |user|
        next unless user.profile.notification == 'email'

        user_messages[user] ||= {}
        user_messages[user][recent_help_key] = messages_lookup[recent_help_key]
      end
    end

    user_messages
  end

  def screening_status_report
    screening_status = {}
    CitationsProject
      .includes(:logs, :citation, project: { projects_users: :user })
      .where(logs: { loggable_type: 'CitationsProject', created_at: 1445.minutes.ago..5.minutes.from_now })
      .each do |citations_project|
      next unless citations_project.logs.present?

      citations_project.project.projects_users.each do |project_user|
        next unless project_user.permissions.to_s(2)[-1] == '1' || project_user.permissions.to_s(2)[-4] == '1'

        newest_log = citations_project.logs.max_by(&:id)
        screening_status[project_user.user] ||= []
        screening_status[project_user.user] << "Citation: #{citations_project.citation.name} was set to '#{newest_log.description}'"
      end
    end

    screening_status
  end

  def extraction_report
    extraction_logs = {}
    Extraction
      .includes(:logs, { citations_project: :citation })
      .where.not(assignor: nil)
      .where(logs: { loggable_type: 'Extraction', created_at: 1445.minutes.ago..5.minutes.from_now })
      .group_by(&:assignor)
      .each do |assignor, extractions|
      log_messages = []
      extractions.each do |extraction|
        next unless extraction.logs.present?

        newest_log = extraction.logs.max_by(&:id)
        log_messages << "Extraction ID: #{extraction.id} (#{extraction.citations_project.citation.name}) was set to '#{newest_log.description}'"
      end
      extraction_logs[assignor] = log_messages
    end

    extraction_logs
  end
end
