require 'json_schemer'

class FhirResourceService
  class << self
    def validate_resource(resource)
      schema_path = Rails.root.join('config', 'schemas', 'fhir.schema.json')
      schema = JSON.parse(File.read(schema_path))

      schemer = JSONSchemer.schema(schema)
      errors = schemer.validate(resource).to_a

      errors.empty?
    end

    def build_identifier(srdrplus_type, srdrplus_id)
      [{
        'type' => { 'text' => 'SRDR+ Object Identifier' },
        'system' => 'https://srdrplus.ahrq.gov/',
        'value' => "#{srdrplus_type}/#{srdrplus_id}"
      }]
    end

    def get_bundle(fhir_objs:, type:, link_info: nil)
      bundle = {
        'resourceType' => 'Bundle',
        'type' => type,
        'link' => link_info,
        'entry' => []
      }

      fhir_objs.each do |fhir_obj|
        if !fhir_obj.blank?
          bundle['entry'] << { 'resource' => fhir_obj }
        end
      end

      bundle
    end

    def get_citation(
      id_prefix:,
      srdrplus_id:,
      srdrplus_type:,
      status:,
      title: nil,
      abstract: nil,
      authors: nil,
      pmid: nil,
      journal_publication_date: nil,
      journal_volume: nil,
      journal_issue: nil,
      journal_published_in: nil
    )
      citation = {
        'resourceType' => 'Citation',
        'status' => status,
        'id' => "#{id_prefix}-#{srdrplus_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id),
      }

      cited_artifact = {}

      cited_artifact['title'] = [{ 'text' => title }] if !title.blank?
      cited_artifact['abstract'] = [{ 'text' => abstract }] if !abstract.blank?

      entries = []
      if !authors.blank?
        authors.split(', ').each_with_index do |author, i|
          author_ref = {
            'resourceType' => 'Practitioner',
            'id' => "author#{i}",
            'name' => [{ 'text' => author }]
          }
          entry = {
            'contributor' => { 'reference' => "#author#{i}" }
          }
          citation['contained'] ||= []
          citation['contained'] << author_ref
          cited_artifact['contributorship'] ||= { 'entry' => [] }
          cited_artifact['contributorship']['entry'] << entry
        end
      end

      journal_info = {}
      journal_info['publicationDateText'] = journal_publication_date if !journal_publication_date.blank?
      journal_info['volume'] = journal_volume if !journal_volume.blank?
      journal_info['issue'] = journal_issue if !journal_issue.blank?
      journal_info['publishedIn'] = { 'title' => journal_published_in } if !journal_published_in.blank?

      cited_artifact['publicationForm'] = [journal_info] unless journal_info.empty?

      if pmid
        cited_artifact['identifier'] = [{
          'system' => 'https://pubmed.ncbi.nlm.nih.gov',
          'value' => pmid
        }]
      end

      citation['citedArtifact'] = cited_artifact unless cited_artifact.empty?

      citation
    end

    def get_evidence_variable(title:, id_prefix:, srdrplus_id:, srdrplus_type:, status:, notes: nil, group_content: nil)
      evidence_variable = {
        'resourceType' => 'EvidenceVariable',
        'status' => status,
        'id' => "#{id_prefix}-#{srdrplus_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id),
        'title' => title,
      }

      if group_content
        evidence_variable['contained'] = build_contained_group(group_content)
        evidence_variable['definition'] = {
          'reference' => {
            'reference' => '#Definition-Group'
          }
        }
      end

      if notes
        evidence_variable['note'] = notes.map { |note| {'text' => note} }
      end

      evidence_variable.compact
    end

    def get_questionnaire(title:, id_prefix:, srdrplus_id:, srdrplus_type:, status:, items: nil)
      questionnaire = {
        'resourceType' => 'Questionnaire',
        'status' => status,
        'id' => "#{id_prefix}-#{srdrplus_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id),
        'title' => title,
      }

      if !items.blank?
        questionnaire['item'] = items
      end

      questionnaire.compact
    end

    def build_contained_group(group_content)
      group = {
        'resourceType' => 'Group',
        'id' => '#Definition-Group',
        'membership' => 'conceptual',
        'combinationMethod' => 'all-of',
        'characteristic' => [],
      }

      group_content.each do |code, value|
        next unless value
        group['characteristic'] << {'description' => value, 'exclude' => false, 'code' => {'text' => code}}
      end

      [group]
    end

    def build_questionnaire_item(
      linkid:,
      type:,
      text: nil,
      repeats: nil,
      maxLength: nil,
      definition: nil,
      extension: nil,
      answer_constraint: nil,
      enable_when_items: nil,
      enable_behavior: nil,
      answer_options: nil,
      items: nil
    )
      main_item = {
        'extension' => extension,
        'linkId' => linkid,
        'definition' => definition,
        'text' => text,
        'type' => type,
        'repeats' => repeats,
        'maxLength' => maxLength,
        'answerConstraint' => answer_constraint,
        'enableBehavior' => enable_behavior,
        'item' => items
      }.compact

      if !answer_options.blank?
        main_item['answerOption'] = answer_options.map { |answer_option| {'valueString' => answer_option} }
      end

      if !enable_when_items.blank?
        main_item['enableWhen'] = enable_when_items.map do |enable_item|
          condition = {
            'question' => enable_item[0],
            'operator' => enable_item[1]
          }

          if enable_item[2].is_a?(String)
            condition['answerString'] = enable_item[2]
          elsif !!enable_item[2] == enable_item[2]
            condition['answerBoolean'] = enable_item[2]
          end

          condition
        end
      end

      main_item
    end
  end
end
