class AutoTrainingJob
  include Sidekiq::Worker

  def perform
    AutoTrainingService.check_and_train_and_predict(100)
  end
end
