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

  def self.before_asr_id(abstract_screening, asr_id, user)
    return nil if abstract_screening.nil? || asr_id.nil? || user.nil?

    AbstractScreeningResult
      .where(
        abstract_screening:,
        user:
      )
      .where(
        'updated_at < ?', AbstractScreeningResult.find_by(id: asr_id).updated_at
      ).order(:updated_at).last
  end
end
