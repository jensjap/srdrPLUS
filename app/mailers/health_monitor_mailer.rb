class HealthMonitorMailer < ApplicationMailer
  def report_findings(title, anomalies)
    @title = title
    @anomalies = anomalies
    mail(to: 'hello@mycenaean.org', subject: 'DB Anomalies Detected')
  end
end
