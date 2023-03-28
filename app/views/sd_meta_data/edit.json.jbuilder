json.section_statuses do
  json.section_flag_0 @sd_meta_datum.section_flag_0
  json.section_flag_1 @sd_meta_datum.section_flag_1
  json.section_flag_2 @sd_meta_datum.section_flag_2
  json.section_flag_3 @sd_meta_datum.section_flag_3
  json.section_flag_4 @sd_meta_datum.section_flag_4
  json.section_flag_5 @sd_meta_datum.section_flag_5
  json.section_flag_6 @sd_meta_datum.section_flag_6
  json.section_flag_7 @sd_meta_datum.section_flag_7
  json.section_flag_8 @sd_meta_datum.section_flag_8
end

case @panel_number
when 0
  # panel 0
  json.project_name @project.name
  json.report_title @sd_meta_datum.report_title
  json.date_of_last_search @sd_meta_datum.date_of_last_search&.strftime('%Y-%m-%d')
  json.date_of_publication_to_srdr @sd_meta_datum.date_of_publication_to_srdr&.strftime('%Y-%m-%d')
  json.date_of_publication_full_report @sd_meta_datum.date_of_publication_full_report&.strftime('%Y-%m-%d')
  json.funding_sources @sd_meta_datum.funding_sources do |funding_source|
    json.id funding_source.id
    json.name funding_source.name
  end
when 1
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
when 2
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
when 3
  # panel 3
  json.overall_purpose_of_review @sd_meta_datum.overall_purpose_of_review
  json.review_types(@sd_meta_datum.review_type ? [@sd_meta_datum.review_type] : []) do |review_type|
    json.id review_type.id
    json.name review_type.name
  end
  json.sd_analytic_frameworks @sd_meta_datum.sd_analytic_frameworks do |sd_analytic_framework|
    json.id sd_analytic_framework.id
    json.name sd_analytic_framework.name
    json.pos sd_analytic_framework.pos
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
    json.pos sd_key_question.pos
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
when 4
  # panel 4
  json.sd_picods @sd_meta_datum.sd_picods do |sd_picod|
    json.id sd_picod.id
    json.pos sd_picod.pos
    json.data_analysis_levels(sd_picod.data_analysis_level ? [sd_picod.data_analysis_level] : []) do |data_analysis_level|
      json.id data_analysis_level&.id
      json.name data_analysis_level&.name
    end
    json.sd_key_questions sd_picod.sd_key_questions do |sd_key_question|
      json.id sd_key_question.id
      json.name sd_key_question.name
      json.pos sd_key_question.pos
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
when 5
  # panel 5
  json.key_questions_projects @sd_meta_datum.project.key_questions_projects do |key_question_project|
    json.id key_question_project.id
    json.name key_question_project.key_question.name
  end
  json.sd_key_questions @sd_meta_datum.sd_key_questions do |sd_key_question|
    json.id sd_key_question.id
    json.name sd_key_question.key_question.name
    json.sd_key_questions_projects sd_key_question.sd_key_questions_projects do |sd_key_questions_project|
      json.id sd_key_questions_project.id
      json.sd_key_question_id sd_key_questions_project.sd_key_question_id
      json.key_questions_project_id sd_key_questions_project.key_questions_project_id
      json.name sd_key_questions_project.key_question.name
    end
  end
when 6
  # panel 6
  json.sd_search_strategies @sd_meta_datum.sd_search_strategies do |sd_search_strategy|
    json.id sd_search_strategy.id
    json.pos sd_search_strategy.pos
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
    json.pos sd_grey_literature_search.pos
  end
  json.sd_prisma_flows @sd_meta_datum.sd_prisma_flows do |sd_prisma_flow|
    json.id sd_prisma_flow.id
    json.name sd_prisma_flow.name
    json.pos sd_prisma_flow.pos
    json.sd_meta_data_figures sd_prisma_flow.sd_meta_data_figures do |sd_meta_data_figure|
      json.id sd_meta_data_figure.id
      json.alt_text sd_meta_data_figure.alt_text
      json.pictures sd_meta_data_figure.pictures do |picture|
        json.id picture.id
        json.url rails_blob_url(picture)
      end
    end
  end
when 7
  # panel 7
  json.sd_summary_of_evidences @sd_meta_datum.sd_summary_of_evidences do |sd_summary_of_evidence|
    json.id sd_summary_of_evidence.id
    json.soe_type sd_summary_of_evidence.soe_type
    json.name sd_summary_of_evidence.name
    json.pos sd_summary_of_evidence.pos
    json.sd_key_questions(sd_summary_of_evidence.sd_key_question ? [sd_summary_of_evidence.sd_key_question] : []) do |sd_key_question|
      json.id sd_key_question.id
      json.name sd_key_question.name
      json.pos sd_key_question.pos
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
when 8
  # panel 8
  json.sd_result_items @sd_meta_datum.sd_result_items do |sd_result_item|
    json.id sd_result_item.id
    json.pos sd_result_item.pos

    json.sd_key_questions(sd_result_item.sd_key_question ? [sd_result_item.sd_key_question] : []) do |sd_key_question|
      json.id sd_key_question.id
      json.name sd_key_question.name
      json.pos sd_key_question.pos
    end

    json.sd_narrative_results sd_result_item.sd_narrative_results do |sd_narrative_result|
      json.id sd_narrative_result.id
      json.narrative_results sd_narrative_result.narrative_results
      json.narrative_results_by_population sd_narrative_result.narrative_results_by_population
      json.narrative_results_by_intervention sd_narrative_result.narrative_results_by_intervention
      json.pos sd_narrative_result.pos
      json.sd_outcomes sd_narrative_result.sd_outcomes do |sd_outcome|
        json.id sd_outcome.id
        json.name sd_outcome.name
      end
    end
    json.sd_evidence_tables sd_result_item.sd_evidence_tables do |sd_evidence_table|
      json.id sd_evidence_table.id
      json.name sd_evidence_table.name
      json.pos sd_evidence_table.pos

      json.sd_outcomes sd_evidence_table.sd_outcomes do |sd_outcome|
        json.id sd_outcome.id
        json.name sd_outcome.name
      end

      json.sd_meta_data_figures sd_evidence_table.sd_meta_data_figures do |sd_meta_data_figure|
        json.id sd_meta_data_figure.id
        json.alt_text sd_meta_data_figure.alt_text
        json.pictures sd_meta_data_figure.pictures do |picture|
          json.id picture.id
          json.url rails_blob_url(picture)
        end
      end
    end
    json.sd_pairwise_meta_analytic_results sd_result_item.sd_pairwise_meta_analytic_results do |sd_pairwise_meta_analytic_result|
      json.id sd_pairwise_meta_analytic_result.id
      json.name sd_pairwise_meta_analytic_result.name
      json.pos sd_pairwise_meta_analytic_result.pos

      json.sd_outcomes sd_pairwise_meta_analytic_result.sd_outcomes do |sd_outcome|
        json.id sd_outcome.id
        json.name sd_outcome.name
      end

      json.sd_meta_data_figures sd_pairwise_meta_analytic_result.sd_meta_data_figures do |sd_meta_data_figure|
        json.id sd_meta_data_figure.id
        json.p_type sd_meta_data_figure.p_type
        json.alt_text sd_meta_data_figure.alt_text
        json.outcome_type sd_meta_data_figure.outcome_type
        json.intervention_name sd_meta_data_figure.intervention_name
        json.comparator_name sd_meta_data_figure.comparator_name
        json.effect_size_measure_name sd_meta_data_figure.effect_size_measure_name
        json.overall_effect_size sd_meta_data_figure.overall_effect_size
        json.overall_95_ci_low sd_meta_data_figure.overall_95_ci_low
        json.overall_95_ci_high sd_meta_data_figure.overall_95_ci_high
        json.overall_i_squared sd_meta_data_figure.overall_i_squared
        json.other_heterogeneity_statistics sd_meta_data_figure.other_heterogeneity_statistics

        json.pictures sd_meta_data_figure.pictures do |picture|
          json.id picture.id
          json.url rails_blob_url(picture)
        end
      end
    end
    json.sd_network_meta_analysis_results sd_result_item.sd_network_meta_analysis_results do |sd_network_meta_analysis_result|
      json.id sd_network_meta_analysis_result.id
      json.name sd_network_meta_analysis_result.name
      json.pos sd_network_meta_analysis_result.pos

      json.sd_outcomes sd_network_meta_analysis_result.sd_outcomes do |sd_outcome|
        json.id sd_outcome.id
        json.name sd_outcome.name
      end

      json.sd_meta_data_figures sd_network_meta_analysis_result.sd_meta_data_figures do |sd_meta_data_figure|
        json.id sd_meta_data_figure.id
        json.p_type sd_meta_data_figure.p_type
        json.alt_text sd_meta_data_figure.alt_text
        json.pictures sd_meta_data_figure.pictures do |picture|
          json.id picture.id
          json.url rails_blob_url(picture)
        end
      end
    end
    json.sd_meta_regression_analysis_results sd_result_item.sd_meta_regression_analysis_results do |sd_meta_regression_analysis_result|
      json.id sd_meta_regression_analysis_result.id
      json.name sd_meta_regression_analysis_result.name
      json.pos sd_meta_regression_analysis_result.pos

      json.sd_outcomes sd_meta_regression_analysis_result.sd_outcomes do |sd_outcome|
        json.id sd_outcome.id
        json.name sd_outcome.name
      end

      json.sd_meta_data_figures sd_meta_regression_analysis_result.sd_meta_data_figures do |sd_meta_data_figure|
        json.id sd_meta_data_figure.id
        json.alt_text sd_meta_data_figure.alt_text
        json.pictures sd_meta_data_figure.pictures do |picture|
          json.id picture.id
          json.url rails_blob_url(picture)
        end
      end
    end
  end
end
