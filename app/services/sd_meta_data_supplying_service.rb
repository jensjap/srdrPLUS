class SdMetaDataSupplyingService

  def find_by_project_id(project_id)
    sd_meta_data_ids = Project.includes(:sd_meta_data).find(project_id).sd_meta_data.ids

    link_info = [
      build_link_info('tag', "api/v3/projects/#{project_id}/sd_meta_data"),
      build_link_info('service-doc', 'doc/fhir/sd_meta_data.txt')
    ]

    sd_meta_data_in_fhir = sd_meta_data_ids.map { |id| find_by_sd_meta_data_id(id) }
    create_bundle(sd_meta_data_in_fhir, 'collection', link_info)
  end

  def find_by_sd_meta_data_id(sd_meta_data_id)
    sd_meta_data = SdMetaDatum.find(sd_meta_data_id)
    sd_outcomes = get_sd_outcomes(sd_meta_data)

    kq_full_url = get_identifier_values(sd_meta_data.sd_key_questions, 'SdKeyQuestion')
    pico_full_url = get_identifier_values(sd_meta_data.sd_picods, 'SdPicod')
    ss_full_url = get_identifier_values(sd_meta_data.sd_search_strategies, 'SdSearchStrategy')
    outcome_full_url = get_identifier_values(sd_outcomes, 'SdOutcome')

    sd_key_questions_in_fhir = sd_meta_data.sd_key_questions.map {|kq| create_key_question_fhir_obj(kq)}
    sd_picod_in_fhir = sd_meta_data.sd_picods.map {|pico| create_picodts_fhir_obj(pico)}
    sd_search_strategy_in_fhir = sd_meta_data.sd_search_strategies.map {|ss| create_search_strategy_fhir_obj(ss)}
    sd_outcome_in_fhir = sd_outcomes.map {|outcome| create_outcome_fhir_obj(outcome)}
    sd_meta_data_in_fhir = create_composition_fhir_obj(sd_meta_data)

    combination_full_url = pico_full_url.dup + kq_full_url.dup + ss_full_url.dup + outcome_full_url.dup
    combination_full_url.unshift(nil)
    combination = sd_picod_in_fhir.dup + sd_key_questions_in_fhir.dup + sd_search_strategy_in_fhir.dup + sd_outcome_in_fhir.dup
    combination.unshift(sd_meta_data_in_fhir)
    create_bundle(fhir_objs=combination, type='document', link_info=nil, full_urls=combination_full_url)
  end

  private

  def create_bundle(fhir_objs, type, link_info=nil, full_urls=nil)
    full_urls ||= []
    valid_objs = fhir_objs.zip(full_urls).each_with_object([]) do |(obj, url), array|
      array << { 'fullUrl' => url, 'resource' => obj }# if obj.valid?
    end
    FHIR::Bundle.new('type' => type, 'link' => link_info, 'entry' => valid_objs)
  end

  def build_link_info(relation, url)
    { 'relation' => relation, 'url' => url }
  end

  def create_composition_fhir_obj(raw)
    composition = build_composition(raw)

    add_date_section(composition, 'Date of Last Search', raw.date_of_last_search)
    add_date_section(composition, 'Date of Publication to SRDR+', raw.date_of_publication_to_srdr)
    add_date_section(composition, 'Date of Publication of Full Report', raw.date_of_publication_full_report)

    add_reference_section(composition, 'Key Questions', raw.sd_key_questions, 'SdKeyQuestion')
    add_reference_section(composition, 'PICODTS', raw.sd_picods, 'SdPicod')
    add_reference_section(composition, 'Search Strategies', raw.sd_search_strategies, 'SdSearchStrategy')

    sd_outcomes = get_sd_outcomes(raw)
    add_reference_section(composition, 'Outcomes', sd_outcomes, 'SdOutcome')

    sections = {
      'Funding Source' => raw.funding_sources&.map { |source| source['name'] },
      'Authors' => raw.authors,
      'Conflicts of Interest of Authors of Full Report' => raw.authors_conflict_of_interest_of_full_report,
      'Stakeholders Involved - Key Informants' => raw.stakeholders_key_informants,
      'Stakeholders Involved - Technical Expert Panel' => raw.stakeholders_technical_experts,
      'Stakeholders Involved - Peer Reviewers' => raw.stakeholders_peer_reviewers,
      'Stakeholders Involved - Others' => raw.stakeholders_others,
      'Overall Purpose of Review' => raw.overall_purpose_of_review,
      'Type of Review' => raw.review_type['name'],
      'Grey Literature Searches' => raw.sd_grey_literature_searches&.map { |source| source['name'] }
    }

    sections.each do |title, value|
      next if value.blank?

      value = [value] unless value.is_a? Array
      value.each do |v|
        add_section(composition, title, v)
      end
    end

    url_items = {
      'PROSPERO Link' => raw.prospero_link,
      'Protocol Link' => raw.protocol_link,
      'Full Report Link' => raw.full_report_link,
      'Structured Abstract Link' => raw.structured_abstract_link,
      'Main Points or Key Messages Link' => raw.key_messages_link,
      'Lay Abstract / Lay Language Summary Link' => raw.abstract_summary_link,
      'Evidence Summary / Executive Summary Link' => raw.evidence_summary_link,
      'Disposition of Comments Link' => raw.disposition_of_comments_link,
      'Downloadable Content Link' => raw.srdr_data_link,
      'Most Recent Previous Version of SRDR+ Data Link' => raw.most_previous_version_srdr_link,
      'Most Recent Previous Version of Full Report Link' => raw.most_previous_version_full_report_link
    }

    url_items.each do |title, url|
      add_url(composition, title, url) if !url.blank?
    end

    raw.sd_journal_article_urls&.each do |source|
      title = 'Journal Article'
      url = source['name']
      add_url(composition, title, url)
    end

    other_items_for_url = raw.sd_other_items&.map { |item| [item['name'], item['url']] }
    other_items_for_url.each do |title, url|
      add_url(composition, title, url)
    end

    sd_analytic_frameworks = raw.sd_analytic_frameworks&.map { |item| [item['name'], item.sd_meta_data_figures] }
    sd_analytic_frameworks.each do |name, figures|
      process_figures(composition, figures, name)
    end

    sd_prisma_flows = raw.sd_prisma_flows&.map { |item| [item['name'], item.sd_meta_data_figures] }
    sd_prisma_flows.each do |name, figures|
      process_figures(composition, figures, name)
    end

    sd_narrative_results = raw.sd_result_items&.map { |item| [item.sd_key_question, item.sd_narrative_results] }
    sd_narrative_results.each do |kq, results|
      results.each do |result|
        entries = [{"reference" => "SdKeyQuestion/#{kq.id}"}]
        result.sd_outcomes.each do |outcome|
          entries << {"reference" => "SdOutcome/#{outcome.id}"}
        end
        add_section(composition, 'Narrative Results', result.narrative_results, entries) if !result.narrative_results.blank?
        add_section(composition, 'Narrative Results by Population', result.narrative_results_by_population, entries) if !result.narrative_results_by_population.blank?
        add_section(composition, 'Narrative Results by Intervention', result.narrative_results_by_intervention, entries) if !result.narrative_results_by_intervention.blank?
      end
    end

    sd_pairwise_meta_analytic_results = raw.sd_result_items&.map { |item| [item.sd_key_question, item.sd_pairwise_meta_analytic_results] }
    create_section_with_entries_and_figures(composition, 'Pairwise Meta-analyses by Outcomes', sd_pairwise_meta_analytic_results)

    sd_evidence_tables = raw.sd_result_items&.map { |item| [item.sd_key_question, item.sd_evidence_tables] }
    create_section_with_entries_and_figures(composition, 'Evidence Table', sd_evidence_tables)

    sd_network_meta_analysis_results = raw.sd_result_items&.map { |item| [item.sd_key_question, item.sd_network_meta_analysis_results] }
    create_section_with_entries_and_figures(composition, 'Network Meta Analysis Results', sd_network_meta_analysis_results)

    sd_meta_regression_analysis_results = raw.sd_result_items&.map { |item| [item.sd_key_question, item.sd_meta_regression_analysis_results] }
    create_section_with_entries_and_figures(composition, 'Meta Regression Analysis Results', sd_meta_regression_analysis_results)

    FHIR::Composition.new(composition)
  end

  def create_evidence_variable_fhir_obj(id_prefix, identifier, title, characteristics_data, notes = nil)
    evidence_variable = {
      'status' => 'active',
      'id' => "#{id_prefix}-#{identifier.id}",
      'identifier' => build_identifier(identifier.class.name, identifier.id),
      'characteristic' => [],
      'note' => [],
      'title' => title,
    }.compact

    characteristics_data.each do |code, value|
      next unless value
      evidence_variable['characteristic'] << {'description' => value, 'definitionCodeableConcept' => {'coding' => [{'code' => code}]}}
    end

    if notes
      notes.each do |note|
        evidence_variable['note'] << {'text' => note}
      end
    end

    FHIR::EvidenceVariable.new(evidence_variable)
  end

  def create_outcome_fhir_obj(raw)
    characteristics_data = [
      ['Outcome', raw.name]
    ]

    create_evidence_variable_fhir_obj('11', raw, 'Outcome', characteristics_data)
  end

  def create_search_strategy_fhir_obj(raw)
    characteristics_data = [
      ['Search Terms', raw.search_terms],
      ['Search Limits', raw.search_limits],
      ['Search Run Date', raw.date_of_search],
      ['Database', raw.sd_search_database&.name]
    ]

    create_evidence_variable_fhir_obj('10', raw, 'Search Strategy', characteristics_data)
  end

  def create_picodts_fhir_obj(raw)
    characteristics_data = [
      ['Population', raw.population],
      ['Intervention', raw.interventions],
      ['Comparator', raw.comparators],
      ['Outcome', raw.outcomes],
      ['Study Design', raw.study_designs],
      ['Timing', raw.timing],
      ['Setting', raw.settings],
      ['Other Element', raw.other_elements],
      ['Data Analysis Level', raw.data_analysis_level&.name]
    ]

    notes = raw.sd_key_questions.map { |sd_key_question| "SdKeyQuestion/#{sd_key_question.id}" }

    create_evidence_variable_fhir_obj('9', raw, 'PICODTS', characteristics_data, notes)
  end

  def create_key_question_fhir_obj(raw)
    characteristics_data = []
    notes = raw.key_question_types.map { |key_question_type| "Types: #{key_question_type['name']}" }

    if raw.includes_meta_analysis
      notes << "Include meta-analysis: #{raw.includes_meta_analysis}"
    end

    create_evidence_variable_fhir_obj('8', raw, raw.name, characteristics_data, notes)
  end

  def get_identifier_values(raw_data, prefix)
    if raw_data.is_a?(ActiveRecord::Relation)
      raw_data.ids.map { |id| "#{prefix}/#{id}" }
    else
      raw_data.map { |raw| "#{prefix}/#{raw.id}" }
    end
  end

  def build_composition(raw)
    sr360_status = raw.all_sections_complete? ? 'final' : 'partial'
    sr360_title = raw.report_title || 'No report title'
    sr360_updated_date = raw.updated_at.strftime("%Y-%m-%dT%H:%M:%S%:z")

    {
      'status' => sr360_status,
      'id' => "7-#{raw.id}",
      'identifier' => build_identifier('SdMetaData', raw.id),
      'type' => { 'text' => 'EvidenceReport' },
      'date' => sr360_updated_date,
      'author' => { 'display' => 'SRDR+' },
      'title' => sr360_title
    }
  end

  def build_identifier(resource, id)
    [{
      'type' => { 'text' => 'SRDR+ Object Identifier' },
      'system' => 'https://srdrplus.ahrq.gov/',
      'value' => "#{resource}/#{id}"
    }]
  end

  def get_sd_outcomes(sd_meta_data)
    sd_outcome_groups = []
    ['sd_pairwise_meta_analytic_results', 'sd_narrative_results', 'sd_evidence_tables', 'sd_network_meta_analysis_results', 'sd_meta_regression_analysis_results'].each do |attr|
      sd_outcomes = sd_meta_data.sd_result_items.map { |item| item.public_send(attr).map(&:sd_outcomes) }.flatten
      sd_outcome_groups << sd_outcomes
    end
    unique_sd_outcomes = sd_outcome_groups.flatten.uniq { |sd_outcome| sd_outcome.id }
    unique_sd_outcomes.sort_by(&:id)
  end

  def add_date_section(composition, title, date)
    return if date.blank?

    value = date.strftime("%Y-%m-%dT%H:%M:%S%:z")
    add_section(composition, title, value)
  end

  def add_reference_section(composition, title, raw_data, prefix)
    id_values = get_identifier_values(raw_data, prefix)

    entrys = id_values.map { |id_value| {'reference' => id_value, 'type' => 'EvidenceVariable'} }
    add_section(composition, title, nil, entrys)
  end

  def add_section(array_or_hash, title=nil, value=nil, entrys=nil)
    code = { 'coding' => [{ 'code' => title }] } if title
    section = {
      'title' => title,
      'code' => code,
      'text' => {
        'status' => 'generated',
        'div' => "<div xmlns=\"http://www.w3.org/1999/xhtml\">#{value}</div>"
      },
      'entry' => entrys
    }.compact

    if array_or_hash.is_a?(Hash)
      array_or_hash['section'] = (array_or_hash['section'] || []) << section
    else
      array_or_hash << { 'section' => [section] }
    end
    section
  end

  def add_related_artifact(composition, type, attributes)
    related_artifact = {
      'type' => type,
      'document' => {
        'url' => attributes[:url],
        'title' => attributes[:title]
      }
    }
    related_artifact['label'] = attributes[:label] if attributes[:label]

    if composition['relatesTo']
      composition['relatesTo'] << related_artifact
    else
      composition['relatesTo'] = [related_artifact]
    end
  end

  def add_url(composition, title, url)
    add_related_artifact(composition, 'supported-with', { url: url, title: title })
  end

  def add_picture(composition, label, display, url)
    add_related_artifact(composition, 'supported-with', { url: url, title: display, label: label })
  end

  def process_figures(composition, figures, name)
    figures.each do |figure|
      process_pictures(composition, figure.pictures, name, figure.alt_text)
    end
  end

  def process_pictures(composition, pictures, name, alt_text)
    pictures.each do |picture|
      url = Rails.application.routes.url_helpers.rails_blob_url(picture, only_path: false)
      add_picture(composition, name, alt_text, url)
    end
  end

  def create_section_with_entries_and_figures(composition, section_name, result_items)
    result_items.each do |item|
      kq = item[0]
      results = item[1]
      results.each do |result|
        entries = [{"reference" => "SdKeyQuestion/#{kq.id}"}]
        result.sd_outcomes.each do |outcome|
          entries << {"reference" => "SdOutcome/#{outcome.id}"}
        end
        framework_section = add_section(composition, section_name, result.name, entries)
        process_figures(composition, result.sd_meta_data_figures, result.name)
      end
    end
  end
end
