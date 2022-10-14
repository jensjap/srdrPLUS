class AbstractScreeningService
  def self.pick_next_citation(as_id, _user_id)
    AbstractScreening.find(as_id).project.citations.sample
  end
end
