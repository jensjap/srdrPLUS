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

    def build_full_url(resources:, relative_path:)
      base_url = 'https://srdrplus.ahrq.gov/api/v3/'
      urls = resources.map do |resource|
        id = resource['id']
        extracted_id = id.split('-').last
        "#{base_url}#{relative_path}#{extracted_id}"
      end
      urls
    end

    def get_list(fhir_objs:)
      fhir_list = {
        'resourceType' => 'List',
        'contained' => [],
        'status' => 'current',
        'mode' => 'snapshot',
        'entry' => []
      }

      fhir_objs.each do |fhir_obj|
        next if fhir_obj.blank?
        fhir_list['contained'] << fhir_obj
        fhir_list['entry'] << { 'item' => { 'reference' => "##{fhir_obj['id']}" } }
      end

      fhir_list
    end

    def get_bundle(fhir_objs:, type:, link_info: nil, full_urls: nil)
      full_urls ||= Array.new(fhir_objs.size)

      fhir_objs = fhir_objs.zip(full_urls).each_with_object([]) do |(obj, url), array|
        entry = { 'resource' => obj }
        entry['fullUrl'] = url if url

        if type == 'transaction'
          resource_type = obj.dig('resourceType')
          resource_id = obj.dig('id')
          if resource_type && resource_id
            entry['request'] = {
              'method' => 'POST',
              'url' => "#{resource_type}/#{resource_id}"
            }
          end
        end

        array << entry
      end

      timestamp = DateTime.now.iso8601(3)

      bundle = {
        'resourceType' => 'Bundle',
        'type' => type,
        'timestamp' => timestamp,
        'link' => link_info,
        'entry' => fhir_objs
      }

      return if bundle['entry'].blank?
      deep_clean(bundle)
    end

    def get_artifact_assessment(
      id_prefix:,
      srdrplus_id:,
      srdrplus_type:,
      artifact_uri:
    )
      {
        'resourceType' => 'ArtifactAssessment',
        'id' => "#{id_prefix}-#{srdrplus_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id),
        'artifactUri' => artifact_uri,
        'content' => []
      }
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

    def get_evidence_variable(title:, id_prefix:, srdrplus_id:, srdrplus_type:, status:, description: nil, notes: nil, group_content: nil)
      evidence_variable = {
        'resourceType' => 'EvidenceVariable',
        'status' => status,
        'id' => "#{id_prefix}-#{srdrplus_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id),
        'title' => title,
        'description' => description
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

    def get_questionnaire_response(
      id_prefix:,
      srdrplus_id:,
      srdrplus_type:,
      status:,
      type1_id:,
      questionnaire_url:,
      items:,
      type1_display: nil
    )
      questionnaire_response = {
        'resourceType' => 'QuestionnaireResponse',
        'status' => status,
        'id' => "#{id_prefix}-#{srdrplus_id}-type1id-#{type1_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id),
        'questionnaire' => questionnaire_url,
        'item' => items,
      }

      if type1_display
        questionnaire_response['subject'] = {
          'reference' => "Type1/#{type1_id}",
          'type' => 'EvidenceVariable',
          'display' => type1_display
        }
      end

      questionnaire_response.compact
    end

    def get_group(
      title:,
      id_prefix:,
      srdrplus_id:,
      srdrplus_type:,
      status:,
      group_content:,
      notes: nil
    )
      group = {
        'resourceType' => 'Group',
        'status' => status,
        'id' => "#{id_prefix}-#{srdrplus_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id),
        'title' => title,
        'membership' => 'conceptual',
        'combinationMethod' => 'all-of',
        'characteristic' => [],
      }

      if !notes.blank?
        group['description'] = notes.join(', ')
      end

      group_content.each do |code, value|
        next unless value
        group['characteristic'] << {'code' => {'text' => code}, 'valueCodeableConcept' => {'text' => value}, 'exclude' => false}
      end

      group.compact
    end

    def get_practitioner(srdrplus_type:, id_prefix:, srdrplus_id:, first_name:, middle_name:, last_name:)
      practitioner = {
        'resourceType' => 'Practitioner',
        'id' => "#{id_prefix}-#{srdrplus_id}",
        'identifier' => build_identifier(srdrplus_type, srdrplus_id)
      }

      name = {}
      name['family'] = last_name if !last_name.blank?
      if first_name || middle_name
        given_names = []
        given_names << first_name if !first_name.blank?
        given_names << middle_name if !middle_name.blank?
        name['given'] = given_names.join(' ') unless given_names.empty?
      end

      practitioner['name'] = [name] unless name.empty?
      practitioner
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

    def build_questionnaire_response_item(linkid:, value:, value_type: 'valueString', item: nil)
      main_item = {
        'linkId' => linkid,
        'answer' => [{
          value_type => value,
          'item' => item
        }.compact]
      }
    end

    def build_evidence_variable_definition(description:, variable_role:, comparator_category: nil, comparator_display: nil)
      definition = {
        'description' => description,
        'variableRole' => variable_role,
        'comparatorCategory' => comparator_category,
      }

      if !comparator_display.blank?
        definition['observed'] = { 'display' => comparator_display }
      end

      definition.compact
    end

    def build_artifact_assessment_content(informationType:, type:, user_ref:, quantity: nil, classifier: nil)
      content = {
        'informationType' => informationType,
        'type' => { 'text' => type }
      }
      content['author'] = { 'reference' => user_ref } if !user_ref.blank?
      content['quantity'] = { 'value' => quantity } if !quantity.blank?
      content['classifier'] = [{ 'text' => classifier }] if !classifier.blank?

      content
    end

    def build_contained_practitioner(id:, email:)
      [{
        'resourceType' => 'Practitioner',
        'id' => id,
        'telecom' => [{
          'system' => 'email',
          'value' => email
        }]
      }]
    end

    def deep_clean(item)
      case item
      when Hash
        cleaned_hash = item.each_with_object({}) do |(key, value), new_hash|
          cleaned_value = deep_clean(value)
          new_hash[key] = cleaned_value unless cleaned_value.nil?
        end
        cleaned_hash.empty? ? nil : cleaned_hash
      when Array
        cleaned_array = item.map { |element| deep_clean(element) }.compact
        cleaned_array.reject! { |element| element.is_a?(Hash) && element.empty? }
        cleaned_array
      else
        item
      end
    end
  end
end
