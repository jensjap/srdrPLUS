class RobotScreenService
  def initialize(project_id, url, method = 'abstract_screenings')
    @project_id = project_id
    @project = Project.find(@project_id)
    @url = url
    @method = method
  end

  def train
    data = MachineLearningDataSupplyingService.get_labeled_abstract(@project_id)
    train_url = "#{@url}/train/#{@method}/#{@project_id}"

    res = HTTParty.post(
      train_url,
      {
        body: { labeled_data: data }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept': 'application/json' },
        timeout: 300
      }
    )

    response_hash = JSON.parse(res.body)
    if response_hash['success']
      timestamp = response_hash['timestamp']
      @project.ml_models.create(timestamp:)
      # ml_model = MlModel.new(project_id: @project_id, timestamp: timestamp)
      # ml_model.save
      "Training complete (model timestamp: #{timestamp})"
    else
      message = response_hash['message']
      "Failed (message: #{message})"
    end
  end

  def predict(timestamp)
    data = MachineLearningDataSupplyingService.get_unlabel_abstract(@project_id)
    predict_url = "#{@url}/predict/#{@method}/#{@project_id}"

    res = HTTParty.post(
      predict_url,
      {
        body: { input_citations: data, timestamp: }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept': 'application/json' },
        timeout: 300
      }
    )

    response_hash = JSON.parse(res.body)
    predictions = response_hash['predictions']

    ml_model = @project.ml_models.find_by(timestamp:)

    data.each_with_index do |citation, index|
      citation_id = citation['citation_id']
      score = predictions[index]

      citations_project = CitationsProject.find_by(citation_id:, project_id: @project_id)

      ml_prediction = MlPrediction.new(citations_project_id: citations_project.id, ml_model_id: ml_model.id, score:)
      ml_prediction.save
    end

    'Predictions saved'
  end
end
