class AbstractScreeningService
  def self.get_asr(abstract_screening, user)
    abstract_screening.project.citations.sample
    citation = abstract_screening.project.citations.sample
    AbstractScreeningResult.find_by(
      abstract_screening:,
      user:,
      label: nil
    ) ||
      AbstractScreeningResult.find_or_create_by!(
        abstract_screening:,
        user:,
        citation:
      )
  end
end
