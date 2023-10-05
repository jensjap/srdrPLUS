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

    project_data = project.abstract_screening_results
                          .includes(citations_project: :citation)
                          .map do |asr|
      citation = asr.citation
      next if citation.name.blank? || citation.abstract.blank? || asr.label.nil?

      label_data = {
        'ti' => citation.name.gsub('"', "'"),
        'abs' => citation.abstract.gsub('"', "'"),
        'label' => asr.label == 1 ? '1' : (asr.label == -1 ? '0' : next)
      }
    end.compact

    project_data.uniq { |hash| hash['ti'] }
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
