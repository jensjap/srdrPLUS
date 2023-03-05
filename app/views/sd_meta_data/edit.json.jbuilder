# panel 0
json.project_name @project.name
json.report_title @sd_meta_datum.report_title
json.date_of_last_search @sd_meta_datum.date_of_last_search.strftime('%Y-%m-%d')
json.date_of_publication_to_srdr @sd_meta_datum.date_of_publication_to_srdr.strftime('%Y-%m-%d')
json.date_of_publication_full_report @sd_meta_datum.date_of_publication_full_report.strftime('%Y-%m-%d')
json.funding_sources @sd_meta_datum.funding_sources do |funding_source|
  json.id funding_source.id
  json.name funding_source.name
end
# panel 1
json.organization @sd_meta_datum.organization
json.authors @sd_meta_datum.authors
json.authors_conflict_of_interest_of_full_report @sd_meta_datum.authors_conflict_of_interest_of_full_report
json.stakeholders_key_informants @sd_meta_datum.stakeholders_key_informants
json.stakeholders_technical_experts @sd_meta_datum.stakeholders_technical_experts
json.stakeholders_peer_reviewers @sd_meta_datum.stakeholders_peer_reviewers
json.stakeholders_others @sd_meta_datum.stakeholders_others
json.leaders @project&.leaders do |user|
  next if user.email.include?('@test.com')

  json.name [user.profile.first_name, user.profile.middle_name, user.profile.last_name].join(' ')
  json.email user.email
end
# panel 2
json.prospero_link @sd_meta_datum.prospero_link
json.protocol_link @sd_meta_datum.protocol_link
json.full_report_link @sd_meta_datum.full_report_link
json.structured_abstract_link @sd_meta_datum.structured_abstract_link
json.key_messages_link @sd_meta_datum.key_messages_link
json.abstract_summary_link @sd_meta_datum.abstract_summary_link
json.evidence_summary_link @sd_meta_datum.evidence_summary_link
json.disposition_of_comments_link @sd_meta_datum.disposition_of_comments_link
json.srdr_data_link @sd_meta_datum.srdr_data_link
json.most_previous_version_srdr_link @sd_meta_datum.most_previous_version_srdr_link
json.most_previous_version_full_report_link @sd_meta_datum.most_previous_version_full_report_link
json.sd_journal_article_urls @sd_meta_datum.sd_journal_article_urls do |sd_journal_article_url|
  json.id sd_journal_article_url.id
  json.name sd_journal_article_url.name
end
json.sd_other_items @sd_meta_datum.sd_other_items do |sd_other_item|
  json.id sd_other_item.id
  json.name sd_other_item.name
end
# panel 3
json.overall_purpose_of_review @sd_meta_datum.overall_purpose_of_review
json.review_types(@sd_meta_datum.review_type ? [@sd_meta_datum.review_type] : []) do |review_type|
  json.id review_type.id
  json.name review_type.name
end
json.sd_analytic_frameworks @sd_meta_datum.sd_analytic_frameworks do |sd_analytic_framework|
  json.id sd_analytic_framework.id
  json.name sd_analytic_framework.name
  json.sd_meta_data_figures sd_analytic_framework.sd_meta_data_figures do |sd_meta_data_figure|
    json.id sd_meta_data_figure.id
    json.alt_text sd_meta_data_figure.alt_text
    json.pictures sd_meta_data_figure.pictures do |picture|
      json.id picture.id
      json.url rails_blob_url(picture)
    end
  end
end
json.sd_key_questions @sd_meta_datum.sd_key_questions do |sd_key_question|
  json.id sd_key_question.id
  json.key_question do
    json.id sd_key_question.key_question&.id
    json.name sd_key_question.key_question&.name
  end
  json.key_question_types sd_key_question.key_question_types do |key_question_type|
    json.id key_question_type.id
    json.name key_question_type.name
  end
  json.includes_meta_analysis sd_key_question.includes_meta_analysis
end
# panel 4
json.sd_picods @sd_meta_datum.sd_picods do |sd_picod|
  json.id sd_picod.id
  json.data_analysis_levels(sd_picod.data_analysis_level ? [sd_picod.data_analysis_level] : []) do |data_analysis_level|
    json.id data_analysis_level&.id
    json.name data_analysis_level&.name
  end
  json.sd_key_questions sd_picod.sd_key_questions do |sd_key_question|
    json.id sd_key_question.id
    json.name sd_key_question.name
  end
  json.name sd_picod.name
  json.population sd_picod.population
  json.interventions sd_picod.interventions
  json.comparators sd_picod.comparators
  json.outcomes sd_picod.outcomes
  json.study_designs sd_picod.study_designs
  json.timing sd_picod.timing
  json.settings sd_picod.settings
  json.other_elements sd_picod.other_elements
end
# panel 6
json.sd_search_strategies @sd_meta_datum.sd_search_strategies do |sd_search_strategy|
  json.id sd_search_strategy.id
  json.sd_search_databases(sd_search_strategy.sd_search_database ? [sd_search_strategy.sd_search_database] : []) do |sd_search_database|
    json.id sd_search_database.id
    json.name sd_search_database.name
  end
  json.date_of_search sd_search_strategy.date_of_search
  json.search_limits sd_search_strategy.search_limits
  json.search_terms sd_search_strategy.search_terms
end
json.sd_grey_literature_searches @sd_meta_datum.sd_grey_literature_searches do |sd_grey_literature_search|
  json.id sd_grey_literature_search.id
  json.name sd_grey_literature_search.name
end
json.sd_prisma_flows @sd_meta_datum.sd_prisma_flows do |sd_prisma_flow|
  json.id sd_prisma_flow.id
  json.name sd_prisma_flow.name
  json.sd_meta_data_figures sd_prisma_flow.sd_meta_data_figures do |sd_meta_data_figure|
    json.id sd_meta_data_figure.id
    json.alt_text sd_meta_data_figure.alt_text
    json.pictures sd_meta_data_figure.pictures do |picture|
      json.id picture.id
      json.url rails_blob_url(picture)
    end
  end
end
# panel 7
json.sd_summary_of_evidences @sd_meta_datum.sd_summary_of_evidences do |sd_summary_of_evidence|
  json.id sd_summary_of_evidence.id
  json.soe_type sd_summary_of_evidence.soe_type
  json.name sd_summary_of_evidence.name
  json.sd_key_questions(sd_summary_of_evidence.sd_key_question ? [sd_summary_of_evidence.sd_key_question] : []) do |sd_key_question|
    json.id sd_key_question.id
    json.name sd_key_question.name
  end
  json.sd_meta_data_figures sd_summary_of_evidence.sd_meta_data_figures do |sd_meta_data_figure|
    json.id sd_meta_data_figure.id
    json.alt_text sd_meta_data_figure.alt_text
    json.pictures sd_meta_data_figure.pictures do |picture|
      json.id picture.id
      json.url rails_blob_url(picture)
    end
  end
end
# panel 8
