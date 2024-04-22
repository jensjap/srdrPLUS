class MachineLearningDataSupplyingService
  # Returns true if we should use fake data and false when
  # real data should be used.
  #
  # @return [Bool] whether to stub the ML data or not
  def self.stub_ml_data?
    if ENV.key?('SRDRPLUS_STUB_ML_DATA')
      ENV['SRDRPLUS_STUB_ML_DATA'].to_bool
    else
      false
    end
  end

  def self.get_labeled_abstract(project_id)
    project = Project.find(project_id)
    return [] unless project.abstract_screening_results.exists?

    project_data = project.abstract_screening_results
                          .includes(citations_project: [:citation, :screening_qualifications])
                          .map do |asr|
      citation = asr.citation
      screening_qualifications = asr.citations_project.screening_qualifications
      as_rejected = screening_qualifications.any? { |sq| sq.qualification_type == 'as-rejected' }
      as_accepted = screening_qualifications.any? { |sq| sq.qualification_type == 'as-accepted' }
      next if citation.name.blank? || citation.abstract.blank? || asr.label.nil?

      label_value = if as_rejected
                      '0'
                    elsif as_accepted
                      '1'
                    else
                      asr.label == 1 ? '1' : '0'
                    end

      label_data = {
        'ti' => citation.name.gsub('"', "'"),
        'abs' => citation.abstract.gsub('"', "'"),
        'label' => label_value,
        'privileged' => asr.privileged || as_accepted || as_rejected
      }
    end.compact

    return project_data

    filtered_data = {}
    unique_data = []

    project_data.each do |data|
      key = [data['ti'], data['abs']]
      if filtered_data.key?(key)
        filtered_data[key] << data
      else
        filtered_data[key] = [data]
      end
    end

    final_data = []

    filtered_data.each do |key, values|
      if values.size > 1
        privileged_data = values.find { |v| v['privileged'] }
        if privileged_data
          final_data << privileged_data.except('privileged')
        else
          same_label_data = values.group_by { |v| v['label'] }
                                  .select { |k, v| v.size > 1 }
                                  .values
                                  .flatten
          final_data << (same_label_data.any? ? same_label_data.first.except('privileged') : nil)
        end
      else
        final_data << values.first.except('privileged')
      end
    end

    final_data.compact
  end

  def self.get_unlabel_abstract(project_id)
    project = Project.find(project_id)

    project_data = project.citations
                          .includes(:citations_projects)
                          .reject do |citation|
      citation.name.blank? || citation.abstract.blank? ||
      CitationsProject.find_by(citation_id: citation.id, project_id: project_id)
                       .abstract_screening_results.present?
    end.map do |citation|
      {
        'citation_id' => citation.id,
        'ti' => citation.name.gsub('"', "'"),
        'abs' => citation.abstract.gsub('"', "'")
      }
    end

    project_data
  end

  def self.get_labeled_abstract_since_last_train(project_id)
    last_train_time = MlModelsProject.where(project_id: project_id).order(created_at: :desc).first&.created_at
    return get_labeled_abstract(project_id) unless last_train_time

    project = Project.find(project_id)

    project_data = project.abstract_screening_results
                          .where('abstract_screening_results.created_at > ? OR abstract_screening_results.updated_at > ?', last_train_time, last_train_time)
                          .includes(citations_project: :citation)
                          .map do |asr|
      citation = asr.citation
      next if citation.name.blank? || citation.abstract.blank? || asr.label.nil?

      {
        'ti' => citation.name.gsub('"', "'"),
        'abs' => citation.abstract.gsub('"', "'"),
        'label' => asr.label == 1 ? '1' : (asr.label == -1 ? '0' : next)
      }
    end.compact

    project_data.uniq { |hash| hash['ti'] }
  end

  def self.get_unlabeled_predictions_with_intervals(project_id)
    unlabeled_abstracts = get_unlabel_abstract(project_id)
    unlabeled_citation_ids = unlabeled_abstracts.map { |abstract| abstract['citation_id'] }
    citations_projects = CitationsProject.where(citation_id: unlabeled_citation_ids, project_id: project_id)

    scores_intervals = Hash.new(0)
    citations_projects.each do |cp|
      prediction = MlPrediction.where(citations_project: cp).order(created_at: :desc).first
      next if prediction.nil? || prediction.score.nil?
      interval = (prediction.score * 10).floor / 10.0
      interval_str = "#{interval}-#{interval + 0.1}"
      scores_intervals[interval_str] += 1
    end

    scores_intervals
  end
end
