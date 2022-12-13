class HealthMonitorMailer < ApplicationMailer
  def report_findings(anomalies, find_critical_table_count_differences)
    @anomalies = anomalies
    @find_critical_table_count_differences = find_critical_table_count_differences
    mail(to: 'hello@mycenaean.org', subject: 'DB Anomalies Detected')
  end
end
