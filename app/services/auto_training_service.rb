class AutoTrainingService
  MAX_RETRIES = 3
  URL = ENV['ML_SERVER']

  def self.check_and_train_and_predict(x)
    Project.where(auto_train: true).each do |project|
      retries = 0

      begin
        new_labels_count = MachineLearningDataSupplyingService.get_labeled_abstract_since_last_train(project.id).size
        last_train_time = project.ml_models_projects.order(created_at: :desc).first&.created_at
        days_since_last_train = (Time.zone.now - (last_train_time || Time.zone.at(0))) / 1.day

        if new_labels_count >= x || (new_labels_count > 0 && days_since_last_train >= 7)
          robot_service = RobotScreenService.new(project.id, URL)
          train_result = robot_service.partial_train_and_predict(80)

          if train_result.include? "Training complete"
            timestamp = train_result.match(/model timestamp: (\S+)\)/)[1]
            robot_service.predict(timestamp)
          end
        end

      rescue => e
        retries += 1
        if retries < MAX_RETRIES
          retry
        else
          Rails.logger.error "training failed for project #{project.id}: #{e.message}"
        end
      end
    end
  end
end
