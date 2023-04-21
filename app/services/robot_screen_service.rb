class RobotScreenService

  def initialize(project_id, url)
    @project_id = project_id
    @url = url
  end

  def train
    data = MachineLearningDataSupplyingService.get_abstract_label(@project_id).first(2)
    train_url = @url + '/train/' + @project_id.to_s

    res = HTTParty.post(
      train_url,
      {
        body: { labeled_data: data }.to_json,
        headers: { 'Content-Type' => 'application/json', 'Accept':'application/json' }
      }
    )

    return res.body
  end

end
