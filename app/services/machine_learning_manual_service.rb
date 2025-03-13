class MachineLearningManualService
  MAX_RETRIES = 6
  URL = ENV['ML_SERVER']
  MIN_NEW_LABEL = 100

  def self.update_project(project_id)
    project = Project.find(project_id)
    Rails.logger.info "Updating project: #{project.name}"
    self.check_and_train_and_predict(project)
  end

  private

  def self.check_and_train_and_predict(project)
    return unless project.abstract_screening_results.exists?

    Rails.logger.info "Abstract screening results exists, proceeding.."
    Rails.logger.info "Fetching data.."
    all_labeled_data = MachineLearningDataSupplyingService.get_labeled_abstract(project.id)
    new_labeled_data = MachineLearningDataSupplyingService.get_labeled_abstract_since_last_train(project.id)
    Rails.logger.info "Done!"
    total_citations_count = project.citations.count
    Rails.logger.info "Total citations count: #{total_citations_count.to_s}"

    retries = 0

    begin
      new_labels_count = new_labeled_data.size
      all_labels_count = all_labeled_data.size
      last_train_time = project.ml_models_projects.order(created_at: :desc).first&.created_at
      days_since_last_train = (Time.zone.now - (last_train_time || Time.zone.at(0))) / 1.day
      labeled_percentage = all_labels_count.to_f / total_citations_count

      #if project.force_training || new_labels_count >= MIN_NEW_LABEL || (new_labels_count > 0 && days_since_last_train >= 2)
      if true
        while retries < MAX_RETRIES
          robot_service = RobotScreenService.new(project.id, URL)
          Rails.logger.info "Successfully instantiated robot_service: #{p robot_service}"
          Rails.logger.info "Contacting ML server next to train.."
          train_result = robot_service.partial_train_and_predict(80)
          Rails.logger.info "Done."
          Rails.logger.info "#{train_result.to_s}"

          if train_result.include? "Training complete"
            Rails.logger.info "\"Training complete\" message received..proceeding to predictions.."
            timestamp = train_result.match(/model timestamp: (\S+)\)/)[1]
            data = MachineLearningDataSupplyingService.get_unlabel_abstract(project.id)
            if data.empty?
              break
            end

            Rails.logger.info "Fetching predictions.."
            predictions, ml_model = robot_service.get_predictions(timestamp, data)

            if labeled_percentage < 0.1
              Rails.logger.info "Labeled percentage below 0.1 threshold."
              robot_service.save_predictions(data, predictions, ml_model)
              break
            else
              Rails.logger.info "Labeled percentage above at least 0.1 threshold."
              Rails.logger.info "Checking predictions.."
              if robot_service.check_predictions(predictions, 0.9, 20)
                Rails.logger.info "Predictions seem reasonable..proceed to saving: data, predictions, ml_model."
                robot_service.save_predictions(data, predictions, ml_model)
                break
              else
                Rails.logger.info "Check predictions failed..retrying.."
                retries += 1
              end
            end
          else
            Rails.logger.info "Did not receive \"Training complete\" message..retrying.."
            retries += 1
          end

          Rails.logger.info "Retry count: #{retries.to_s}"

          if retries >= MAX_RETRIES && ml_model
            Rails.logger.warn "Too many retries - unstable model. Destroying this model.."
            ml_model.destroy
          end
        end

        Rails.logger.info "Updating project ID #{project.id.to_s}: \"#{project.name}\" finished! Have a nice day."
        project.update(force_training: false)
      end

    rescue => e
      raise StandardError.new("Error for project #{project.id}: #{e.message}")
    end
  end
end
