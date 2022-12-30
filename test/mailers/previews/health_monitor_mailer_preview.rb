class HealthMonitorMailerPreview < ActionMailer::Preview
  def report_findings
    HealthMonitorMailer.report_findings(
      'Report Title Here',
      {
        'User' => {
          'before' => 100,
          'current' => 90
        }
      }
    )
  end
end
