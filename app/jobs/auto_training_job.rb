class AutoTrainingJob
  include Sidekiq::Worker

  def perform
    return unless ENV['AUTOTRAIN'] == 'true'

    begin
      AutoTrainingService.check_and_train_and_predict(100)
    rescue => e
      AutoTrainingMailer.send_error_notification('hello@mycenaean.org', e.message).deliver_now
    end
  end
end
