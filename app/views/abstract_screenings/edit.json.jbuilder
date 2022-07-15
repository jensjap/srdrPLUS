json.abstract_screening do
  json.type @abstract_screening.abstract_screening_type
  json.all_tag @abstract_screening.yes_tag_required && @abstract_screening.no_tag_required && @abstract_screening.maybe_tag_required
  json.all_reason @abstract_screening.no_reason_required && @abstract_screening.maybe_reason_required
  json.all_note @abstract_screening.yes_note_required && @abstract_screening.no_note_required && @abstract_screening.maybe_note_required
  json.yes_tag @abstract_screening.yes_tag_required
  json.no_tag @abstract_screening.no_tag_required
  json.maybe_tag @abstract_screening.maybe_tag_required
  json.yes_reason @abstract_screening.yes_reason_required
  json.no_reason @abstract_screening.no_reason_required
  json.maybe_reason @abstract_screening.maybe_reason_required
  json.yes_note @abstract_screening.yes_note_required
  json.no_note @abstract_screening.no_note_required
  json.maybe_note @abstract_screening.maybe_note_required
  json.only_predefined_reasons @abstract_screening.only_predefined_reasons
  json.only_predefined_tags @abstract_screening.only_predefined_tags
  json.hide_author @abstract_screening.hide_author
  json.hide_journal @abstract_screening.hide_journal
  json.exclusive_participants @abstract_screening.exclusive_participants
  json.projects_users_role_ids do
    json.selections @abstract_screening.projects_users_roles.map { |pur| { key: pur.id, value: pur.handle } }
    json.options @abstract_screening.project.projects_users_roles.map { |pur| { key: pur.id, value: pur.handle } }
  end
end
