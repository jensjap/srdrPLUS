class EppiService

  def export_by_project_id(id)
    extractions = Project.find(id).extractions
    attributes = []
    references = []

    extractions.each do |extraction|
      attributes << get_attribute(extraction)
      references << get_reference(extraction)
    end

    output = {
      'CodeSets' => [{
        'SetName' => "srdrplus project #{id}",
        'Attributes' => {
          'AttributesList' => merge_attributes(attributes)
        }
      }],
      'References' => references
    }
    return output
  end

  private

  def get_attribute(extraction)
    arms = []
    outcomes = []

    sections_hash = extraction.extractions_extraction_forms_projects_sections.index_by(&:section_name)
    arm_section = sections_hash["Arms"]
    outcome_section = sections_hash["Outcomes"]

    arm_section.extractions_extraction_forms_projects_sections_type1s.each do |eefps_type1|
      type1 = eefps_type1.type1
      arms << {
        'AttributeId' => type1.id,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => type1.name
      }
    end

    outcome_section.extractions_extraction_forms_projects_sections_type1s.each do |eefps_type1|
      type1 = eefps_type1.type1
      outcomes << {
        'AttributeId' => type1.id,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => type1.name
      }
    end

    attribute = [
      {
        'AttributeId' => -1,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Interventions',
        'Attributes' => {
          'AttributesList' => arms
        }
      },
      {
        'AttributeId' => -2,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Outcomes',
        'Attributes' => {
          'AttributesList' => outcomes
        }
      }
    ]
    return attribute
  end

  def get_reference(extraction)
    codes = []
    type1_sections = extraction.extractions_extraction_forms_projects_sections.select do |section|
      ['Arms', 'Outcomes'].include?(section.section_name)
    end
    type1_sections.each do |type1_section|
      type1_section.extractions_extraction_forms_projects_sections_type1s.each do |eefps_type1|
        codes << {
          'AttributeId' => eefps_type1.type1.id,
          'ItemAttributeFullTextDetails' => []
        }
      end
    end

    citation = extraction.citations_project.citation
    reference = {
      'Codes' => codes,
      'Outcomes' => [],
      'Title' => citation.name || '',
      'ParentTitle' => '',
      'ShortTitle' => '',
      'DateCreated' => citation.created_at,
      'CreatedBy' => '',
      'DateEdited' => citation.updated_at || '',
      'EditedBy' => '',
      'Year' => '',
      'Month' => '',
      'StandardNumber' => '',
      'City' => '',
      'Country' => '',
      'Publisher' => '',
      'Institution' => '',
      'Volume' => '',
      'Pages' => '',
      'Edition' => '',
      'Issue' => '',
      'Availability' => '',
      'URL' => '',
      'OldItemId' => '',
      'Abstract' => citation.abstract || '',
      'Comments' => '',
      'TypeName' => 'Journal, Article',
      'Authors' => (citation.authors && citation.authors.gsub(',', ';')) || '',
      'ParentAuthors' => '',
      'DOI' => citation.doi || '',
      'Keywords' => '',
      'ItemStatus' => '',
      'ItemStatusTooltip' => '',
      'QuickCitation' => ''
    }
  end

  def merge_attributes(attributes_list)
    merged_arms = []
    merged_outcomes = []

    attributes_list.each do |attribute|
      interventions = attribute.detect { |a| a['AttributeName'] == 'Interventions' }
      outcomes = attribute.detect { |a| a['AttributeName'] == 'Outcomes' }

      merged_arms += interventions['Attributes']['AttributesList'] if interventions
      merged_outcomes += outcomes['Attributes']['AttributesList'] if outcomes
    end

    [
      {
        'AttributeId' => -1,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Interventions',
        'Attributes' => {
          'AttributesList' => merged_arms.uniq
        }
      },
      {
        'AttributeId' => -2,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Outcomes',
        'Attributes' => {
          'AttributesList' => merged_outcomes.uniq
        }
      }
    ]
  end

end
