class RobotScreenService
  def initialize(project_id, url, method = 'abstract_screenings')
    @project_id = project_id
    @project = Project.find(@project_id)
    @url = url
    @method = method
  end

  def send_post_request(url, body)
    res = HTTParty.post(
      url,
      {
        body: body.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept': 'application/json' },
        timeout: 300
      }
    )
    JSON.parse(res.body)
  end

  def check_labels(data)
    labels = data.map { |item| item['label'] }.uniq
    labels.include?('0') && labels.include?('1')
  end

  def train
    data = MachineLearningDataSupplyingService.get_labeled_abstract(@project_id)

    return "Failed (message: The training data must contain both '0' and '1' labels)" unless check_labels(data)

    train_url = "#{@url}/train/#{@method}/#{@project_id}"
    response_hash = send_post_request(train_url, { labeled_data: data })

    if response_hash['success']
      timestamp = response_hash['timestamp']
      @project.ml_models.create(timestamp: timestamp)
      "Training complete (model timestamp: #{timestamp})"
    else
      "Failed (message: #{response_hash['message']})"
    end
  end

  def predict(timestamp)
    data = MachineLearningDataSupplyingService.get_unlabel_abstract(@project_id)

    predict_url = "#{@url}/predict/#{@method}/#{@project_id}"
    response_hash = send_post_request(predict_url, { input_citations: data, timestamp: timestamp })
    predictions = response_hash['predictions']
    ml_model = @project.ml_models.find_by(timestamp: timestamp)

    data.each_with_index do |citation, index|
      citation_id = citation['citation_id']
      score = predictions[index]
      citations_project = CitationsProject.find_by(citation_id: citation_id, project_id: @project_id)
      ml_prediction = MlPrediction.new(citations_project_id: citations_project.id, ml_model_id: ml_model.id, score: score)
      ml_prediction.save
    end
    'Predictions saved'
  end

  def partial_train_and_predict(x)
    all_data = MachineLearningDataSupplyingService.get_labeled_abstract(@project_id)
    return "Failed (message: The training data must contain both '0' and '1' labels)" unless check_labels(all_data)

    data_0 = all_data.select { |data| data['label'] == '0' }
    data_1 = all_data.select { |data| data['label'] == '1' }
    train_size_0 = [(data_0.size * (x / 100.0)).round, 1].max
    train_size_1 = [(data_1.size * (x / 100.0)).round, 1].max
    train_data = data_0.take(train_size_0) + data_1.take(train_size_1)
    predict_data = data_0.drop(train_size_0) + data_1.drop(train_size_1)

    train_url = "#{@url}/train/#{@method}/#{@project_id}"
    train_response_hash = send_post_request(train_url, { labeled_data: train_data })
    return "Failed (message: #{train_response_hash['message']})" unless train_response_hash['success']
    timestamp = train_response_hash['timestamp']
    @project.ml_models.create(timestamp: timestamp)

    predict_url = "#{@url}/predict/#{@method}/#{@project_id}"
    predict_response_hash = send_post_request(predict_url, { input_citations: predict_data, timestamp: timestamp })
    predictions = predict_response_hash['predictions']
    ml_model = @project.ml_models.find_by(timestamp: timestamp)
    human_labels = predict_data.map { |data| data['label'] }
    [human_labels, predictions]
  end
end
