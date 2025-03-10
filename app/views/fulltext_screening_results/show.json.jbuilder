json.fsr do
  json.id @fulltext_screening_result.id
  json.user_id = @fulltext_screening_result.user_id
  json.username @fulltext_screening_result.user.profile.username
  json.label @fulltext_screening_result.label
  json.custom_reasons @custom_reasons
  json.custom_tags @custom_tags
  json.notes @fulltext_screening_result.notes || ''
  json.form_complete @fulltext_screening_result.form_complete
end
json.citation do
  json.citation_id @fulltext_screening_result.citation.id
  json.title @fulltext_screening_result.citation.name
  json.journal @fulltext_screening.hide_journal ? '<hidden>' : @fulltext_screening_result.citation.journal&.name
  json.authors @fulltext_screening.hide_author ? '<hidden>' : @fulltext_screening_result.citation.authors
  json.abstract @fulltext_screening_result.citation.abstract
  json.keywords @fulltext_screening_result.citation.keywords.map(&:name).join(',')
  json.id @fulltext_screening_result.citation.accession_number_alts
  json.journal_meta_info "#{@fulltext_screening_result.citation.authors}\n#{@fulltext_screening_result.citation.journal&.name}, #{@fulltext_screening_result.citation.year}; #{@fulltext_screening_result.citation.journal&.volume} (#{@fulltext_screening_result.citation.journal&.issue}): #{@fulltext_screening_result.citation.page_number_start}-#{@fulltext_screening_result.citation.page_number_end}. DOI: #{@fulltext_screening_result.citation.doi}. PMID: #{@fulltext_screening_result.citation.pmid}"
end
json.options do
  json.yes_tag_required @fulltext_screening.yes_tag_required
  json.no_tag_required @fulltext_screening.no_tag_required
  json.maybe_tag_required @fulltext_screening.maybe_tag_required
  json.yes_reason_required @fulltext_screening.yes_reason_required
  json.no_reason_required @fulltext_screening.no_reason_required
  json.maybe_reason_required @fulltext_screening.maybe_reason_required
  json.yes_note_required @fulltext_screening.yes_note_required
  json.no_note_required @fulltext_screening.no_note_required
  json.maybe_note_required @fulltext_screening.maybe_note_required
  json.yes_form_required @fulltext_screening.yes_form_required
  json.no_form_required @fulltext_screening.no_form_required
  json.maybe_form_required @fulltext_screening.maybe_form_required
end
cps = @screened_cps.map do |fsr|
  {
    fsr_id: fsr.id,
    name: fsr.citation.name,
    authors: @fulltext_screening.hide_author ? '<hidden>' : fsr.citation.authors,
    label: fsr.label,
    privileged: fsr.privileged
  }
end
json.cps cps
json.all_labels @all_labels
json.project_id @fulltext_screening_result.project.id
json.fsr_in_fsic_count FulltextScreeningService.fsr_in_fsic_count(@fulltext_screening)
