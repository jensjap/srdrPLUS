class HealthMonitorMailerPreview < ActionMailer::Preview
  def report_findings
    HealthMonitorMailer.report_findings(
      {
        'User' => {
          'before' => 100,
          'current' => 90
        }
      },
      {
        'ExtractionForm' => {
          'normal' => 3,
          'current' => 2
        }
      }
    )
  end
end
