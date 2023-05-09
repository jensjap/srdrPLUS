class RobotScreenService

  def initialize(project_id, url, method='abstract_screenings')
    @project_id = project_id
    @url = url
    @method = method
  end

  def train
    data = MachineLearningDataSupplyingService.get_labeled_abstract(@project_id)
    train_url = @url + '/train/' + @method + '/' + @project_id.to_s

    res = HTTParty.post(
      train_url,
      {
        body: { labeled_data: data }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept':'application/json' },
        timeout: 300
      }
    )

    return res.body
  end

  def predict(timestamp)
    data = MachineLearningDataSupplyingService.get_unlabel_abstract(@project_id)
    predict_url = @url + '/predict/' + @method + '/' + @project_id.to_s

    res = HTTParty.post(
      predict_url,
      {
        body: { input_citations: data, timestamp: timestamp }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept':'application/json' },
        timeout: 300
      }
    )

    return res.body
  end

end
