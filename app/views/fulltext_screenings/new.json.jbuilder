json.fulltext_screening do
  json.fulltext_screening_type do
    json.selection(
      {
        key: @fulltext_screening.fulltext_screening_type,
        value: FulltextScreening::FULLTEXTSCREENINGTYPES[@fulltext_screening.fulltext_screening_type]
      }
    )
    json.options(FulltextScreening::FULLTEXTSCREENINGTYPES.map { |key, value| { key:, value: } })
  end
  json.all_tag @fulltext_screening.yes_tag_required && @fulltext_screening.no_tag_required && @fulltext_screening.maybe_tag_required
  json.all_reason @fulltext_screening.no_reason_required && @fulltext_screening.maybe_reason_required
  json.all_note @fulltext_screening.yes_note_required && @fulltext_screening.no_note_required && @fulltext_screening.maybe_note_required
  json.no_of_citations @fulltext_screening.no_of_citations
  json.exclusive_users @fulltext_screening.exclusive_users
  json.yes_tag @fulltext_screening.yes_tag_required
  json.no_tag @fulltext_screening.no_tag_required
  json.maybe_tag @fulltext_screening.maybe_tag_required
  json.yes_reason @fulltext_screening.yes_reason_required
  json.no_reason @fulltext_screening.no_reason_required
  json.maybe_reason @fulltext_screening.maybe_reason_required
  json.yes_note @fulltext_screening.yes_note_required
  json.no_note @fulltext_screening.no_note_required
  json.maybe_note @fulltext_screening.maybe_note_required
  json.only_predefined_reasons @fulltext_screening.only_predefined_reasons
  json.only_predefined_tags @fulltext_screening.only_predefined_tags
  json.hide_author @fulltext_screening.hide_author
  json.hide_journal @fulltext_screening.hide_journal
  json.user_ids do
    json.selections @fulltext_screening.fulltext_screenings_users.map { |asu| { key: asu.id, value: asu.handle } }
    json.options @fulltext_screening.project.users.map { |u| { key: u.id, value: u.handle } }
  end
  json.reason_ids do
    json.selections @fulltext_screening.reasons.map { |reason| { key: reason.id, value: reason.name } }
    json.options @fulltext_screening.reasons.map { |reason| { key: reason.id, value: reason.name } }
  end
  json.tag_ids do
    json.selections @fulltext_screening.tags.map { |tag| { key: tag.id, value: tag.name } }
    json.options @fulltext_screening.tags.map { |tags| { key: tags.id, value: tags.name } }
  end
end
