json.word_weights WordWeight.word_weights_object(current_user, @abstract_screening)
json.asr do
  json.id @abstract_screening_result.id
  json.user_id = @abstract_screening_result.user_id
  json.label @abstract_screening_result.label
  json.predefined_reasons @predefined_reasons
  json.predefined_tags @predefined_tags
  json.custom_reasons @custom_reasons
  json.custom_tags @custom_tags
  json.notes @abstract_screening_result.notes || ''
end
json.citation do
  json.citation_id @abstract_screening_result.citation.id
  json.title @abstract_screening_result.citation.name
  json.journal @abstract_screening.hide_journal ? '<hidden>' : @abstract_screening_result.citation.journal&.name
  json.authors @abstract_screening.hide_author ? '<hidden>' : @abstract_screening_result.citation.authors
  json.abstract @abstract_screening_result.citation.abstract
  json.keywords @abstract_screening_result.citation.keywords.map(&:name).join(',')
  json.id @abstract_screening_result.citation.accession_number_alts
  json.journal_meta_info "#{@abstract_screening_result.citation.authors}\n#{@abstract_screening_result.citation.journal&.name}, #{@abstract_screening_result.citation.year}; #{@abstract_screening_result.citation.journal&.volume} (#{@abstract_screening_result.citation.journal&.issue}): #{@abstract_screening_result.citation.page_number_start}-#{@abstract_screening_result.citation.page_number_end}. DOI: #{@abstract_screening_result.citation.doi}. PMID: #{@abstract_screening_result.citation.pmid}"
end
json.options do
  json.yes_tag_required @abstract_screening.yes_tag_required
  json.no_tag_required @abstract_screening.no_tag_required
  json.maybe_tag_required @abstract_screening.maybe_tag_required
  json.yes_reason_required @abstract_screening.yes_reason_required
  json.no_reason_required @abstract_screening.no_reason_required
  json.maybe_reason_required @abstract_screening.maybe_reason_required
  json.yes_note_required @abstract_screening.yes_note_required
  json.no_note_required @abstract_screening.no_note_required
  json.maybe_note_required @abstract_screening.maybe_note_required
  json.only_predefined_reasons @abstract_screening.only_predefined_reasons
  json.only_predefined_tags @abstract_screening.only_predefined_tags
end
cps = @screened_cps.reverse.map do |asr|
  {
    asr_id: asr.id,
    name: asr.citation.name,
    label: asr.label
  }
end
json.cps cps

json.all_labels @all_labels
