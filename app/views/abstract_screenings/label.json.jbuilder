json.predefined_reasons @predefined_reasons
json.predefined_tags @predefined_tags
json.custom_reasons @custom_reasons
json.custom_tags @custom_tags
json.notes @abstract_screening_result.note&.value || ''
json.label_value @abstract_screening_result.label
json.word_weights @abstract_screenings_projects_users_role.word_weights_object
json.rescreen @abstract_screening_result.id
json.abstract_screening_result_id @abstract_screening_result.id
json.citation do
  json.abstract_screening_id @abstract_screening.id
  json.abstract_screenings_citations_project_id @abstract_screenings_citations_project.id
  json.title @random_citation.name
  json.journal @abstract_screening.hide_journal ? '<hidden>' : @random_citation.journal.name
  json.authors @abstract_screening.hide_author ? '<hidden>' : @random_citation.author_map_string
  json.abstract @random_citation.abstract
  json.keywords @random_citation.keywords.map(&:name).join(',')
  json.id @random_citation.accession_number_alts
  json.journal_meta_info "#{@random_citation.author_map_string}\n#{@random_citation.journal.name}, #{@random_citation.year}; #{@random_citation.journal.volume} (#{@random_citation.journal.issue}): #{@random_citation.page_number_start}-#{@random_citation.page_number_end}. DOI: #{@random_citation.doi}. PMID: #{@random_citation.pmid}"
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
