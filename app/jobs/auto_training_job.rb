class AutoTrainingJob
  include Sidekiq::Worker

  def perform
    AutoTrainingService.check_and_train(100)
  end
end
