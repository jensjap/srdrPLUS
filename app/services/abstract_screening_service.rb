class AbstractScreeningService
  def self.get_asr(abstract_screening, user)
    abstract_screening.project.citations.sample
    finished_citations_ids = abstract_screening.abstract_screening_results.where(user:).map(&:citation).flatten.map(&:id)
    citation = abstract_screening.project.citations.where.not(id: finished_citations_ids).sample
    return nil if citation.blank?

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
    return nil if abstract_screening.blank? || asr_id.blank? || user.blank?

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
