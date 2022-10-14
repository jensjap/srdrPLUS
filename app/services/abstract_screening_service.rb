class AbstractScreeningService
  def self.pick_next_citation(_as_id, _user_id)
    Citation.first
  end
end
