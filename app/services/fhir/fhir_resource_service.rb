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

    def get_bundle(fhir_objs, type, link_info=nil)
      bundle = {
        'resourceType' => 'Bundle',
        'type' => type,
        'link' => link_info,
        'entry' => []
      }

      for fhir_obj in fhir_objs do
        bundle['entry'].append({ 'resource' => fhir_obj }) if validate_resource(fhir_obj)
      end

      bundle
    end

    def get_evidence_variable(title, id_prefix, srdrplus_id, srdrplus_type, status, notes = nil, group_content = nil)
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
  end
end
