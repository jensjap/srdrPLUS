class AutoTrainingService
  MAX_RETRIES = 6
  URL = ENV['ML_SERVER']

  def self.check_and_train_and_predict(x)
    Project.all.each do |project|
      next unless project.abstract_screening_results.exists?

      all_labeled_data = MachineLearningDataSupplyingService.get_labeled_abstract(project.id)
      new_labeled_data = MachineLearningDataSupplyingService.get_labeled_abstract_since_last_train(project.id)
      total_citations_count = project.citations.count

      retries = 0

      begin
        new_labels_count = new_labeled_data.size
        all_labels_count = all_labeled_data.size
        last_train_time = project.ml_models_projects.order(created_at: :desc).first&.created_at
        days_since_last_train = (Time.zone.now - (last_train_time || Time.zone.at(0))) / 1.day
        labeled_percentage = all_labels_count.to_f / total_citations_count

        if project.force_training || new_labels_count >= x || (new_labels_count > 0 && days_since_last_train >= 7)
          while retries < MAX_RETRIES
            robot_service = RobotScreenService.new(project.id, URL)
            train_result = robot_service.partial_train_and_predict(80)

            if train_result.include? "Training complete"
              timestamp = train_result.match(/model timestamp: (\S+)\)/)[1]
              data = MachineLearningDataSupplyingService.get_unlabel_abstract(project.id)
              if data.empty?
                break
              end

              predictions, ml_model = robot_service.get_predictions(timestamp, data)

              if labeled_percentage < 0.1
                robot_service.save_predictions(data, predictions, ml_model, project)
                break
              else
                if robot_service.check_predictions(predictions, 0.9, 20)
                  robot_service.save_predictions(data, predictions, ml_model, project)
                  break
                else
                  retries += 1
                end
              end
            else
              retries += 1
            end

            if retries >= MAX_RETRIES && ml_model
              ml_model.destroy
            end
          end

          project.update(force_training: false)
        end

      rescue => e
        raise StandardError.new("Error for project #{project.id}: #{e.message}")
      end
    end
  end
end
