class AutoTrainingService
  MAX_RETRIES = 3
  URL = ENV['ML_SERVER']

  def self.check_and_train(x)
    retries = 0
    begin
      Project.where(auto_train: true).each do |project|
        new_labels_count = MachineLearningDataSupplyingService.get_labeled_abstract_since_last_train(project.id).size
        last_train_time = project.ml_models_projects.order(created_at: :desc).first&.created_at
        days_since_last_train = (Time.zone.now - (last_train_time || Time.zone.at(0))) / 1.day

        if new_labels_count >= x || (new_labels_count > 0 && days_since_last_train >= 7)
          RobotScreenService.new(project.id, URL).partial_train_and_predict(80)
        end
      end
    rescue => e
      retries += 1
      retry if retries < MAX_RETRIES
      Rails.logger.error "training failed: #{e.message}"
    end
  end
end
