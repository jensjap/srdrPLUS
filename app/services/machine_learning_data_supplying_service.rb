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
    project_data = []

    for asr in project.abstract_screening_results
                      .includes(citations_project: :citation) do
      label_data = {
        'ti' => '',
        'abs' => '',
        'label' => ''
      }
      citation = asr.citation

      ti = citation.name.gsub('"', "'")
      if ti.nil? || ti.empty?
        next
      else
        label_data['ti'] = ti
      end

      abs = citation.abstract.gsub('"', "'")
      if abs.nil? || abs.empty?
        next
      else
        label_data['abs'] = abs
      end

      label = asr.label
      if label.nil?
        next
      else
        if label == 1
          label_data['label'] = '1'
        elsif label == -1
          label_data['label'] = '0'
        else
          next
        end
      end

      project_data.append(label_data)
    end

    unique_project_data = project_data.uniq { |hash| hash['ti'] }
    return unique_project_data
  end

  def self.get_unlabel_abstract(project_id)
    project = Project.find(project_id)
    project_data = []

    for citation in project.citations do
      label_data = {
        'citation_id' => citation.id,
        'ti' => '',
        'abs' => '',
      }

      ti = citation.name.gsub('"', "'")
      if ti.nil? || ti.empty?
        next
      else
        label_data['ti'] = ti
      end

      abs = citation.abstract.gsub('"', "'")
      if abs.nil? || abs.empty?
        next
      else
        label_data['abs'] = abs
      end

      citations_project = CitationsProject.find_by(citation_id: citation.id, project_id: project_id)
      asr = citations_project.abstract_screening_results
      if asr.blank?
        project_data.append(label_data)
      else
        next
      end

    end

    return project_data
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
