require 'json'

class EppiService

  def export_2847
    extractions = Project.find(2847).extractions
    refs = []
    attributes_mapping = get_attributes_id_mapping()

    extractions.each do |extraction|
      design_section, index_section = get_sections(extraction)
      if design_section.status['name'] == 'Completed' and index_section.status['name'] == 'Completed'
        ref_code = get_ref_code_2847(design_section, index_section)
        refs << get_reference_2847(extraction, ref_code)
      end
    end

    attributes_mapping, refs = update_ref_codes_and_attributes(attributes_mapping, refs)
    refs = transform_codes(refs)

    attributes = transform_attributes(attributes_mapping)
    layered_attributes = get_layered_attributes(attributes)

    output = {
      'CodeSets' => [{
        'SetName' => "srdrplus project 2847",
        'Attributes' => layered_attributes
      }],
      'References' => refs
    }

    json_output = JSON.pretty_generate(output)

    File.open("output_2847.json", "w") do |file|
      file.write(json_output)
    end

    return output
  end

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

  def get_attributes_2847()
    designs = [
      {
        'AttributeId' => 1,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Cohort (retrospective or prospective)'
      },
      {
        'AttributeId' => 2,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Case Report or Case Study'
      },
      {
        'AttributeId' => 3,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Case Series'
      },
      {
        'AttributeId' => 4,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Case Control'
      }
    ]

    article_purposes = [
      {
        'AttributeId' => 5,
        'AttributeType' => 'Selectable (show checkbox)',
        'AttributeName' => 'Case Control'
      }
    ]
  end

  def get_attributes_id_mapping()
    attributes = {
      'designs' => {
        'Cohort (retrospective or prospective)' => 1,
        'Case Report or Case Study' => 2,
        'Case Series' => 3,
        'Case Control' => 4
      },
      'article_purposes' => {
        'Case Characterization' => 5,
        'Link Exposure to Outcome' => 6,
        'Modeling Non-Exposure Features' => 7,
        'Prevalence of Conditions' => 8,
        'Other' => 9
      },
      'exposure_measurements' => {
        'Deployed v Non-deployed' => 10,
        'Deployed v Controls (civilian or healthy)' => 11,
        'Deployed Only' => 12,
        'Proximity (Location)' => 13,
        'Seeking Clinical Care' => 14,
        'Self Report' => 15,
        'Specific toxin or insult' => 16,
        'Time in theater' => 17,
        'None' => 18,
        'Other' => 19
      },
      'outcomes_measurements' => {
        'Medical Record (e.g., ICD codes)' => 20,
        'Diagnostics and Morphology' => 21,
        'Pulmonary Function' => 22,
        'Self Report (e.g., survey questionnaire)' => 23,
        'Other' => 24
      },
      'conflict_periods' => {
        'Gulf War (1990-1991)' => 25,
        'Iraq and Afghanistan Conflicts (2001-2021)' => 26,
        'Not specified' => 27
      },
      'airway_inflammation_thickening' => {
        'Airway Inflammation (e.g., pleurisy)' => 28,
        'Airway Thickening' => 29
      },
      'interstitial_lung_diseasess' => {
        'Interstitial Pneumonia' => 30,
        'Pulmonary Fibrosis (idiopathic or otherwise)' => 31,
        'Alveolitis, Extrinsic Allergic' => 32,
        'Interstitial Granulomatous Disease' => 33,
        'Pneumoconiosis' => 34,
        'Other' => 35,
        'DRRD (deployment-related respiratory disease) or DLDD (Deployment Related Distal Lung Disease)' => 36
      },
      'obstructive_lung_diseases' => {
        'Airway Obstruction Not Specified' => 37,
        'Asthma' => 38,
        'Bronchitis' => 39,
        'Bronchiolitis' => 40,
        'Bronchiolitis Obliterans / Constrictive Bronchiolitis' => 41,
        'Bronchiectasis' => 42,
        'Chronic Obstructive Pulmonary Disease' => 43,
        'Emphysema' => 44,
        'DLA (Deployment Related Asthma)' => 45
      },
      'respiratory_tract_infections' => {
        'Pharyngitis' => 46,
        'Sinusitis' => 47,
        'Other' => 48
      },
      'other_respiratory_diseases' => {
        'Respiratory Disease Not Specified' => 49,
        'Smoking Related Disease' => 50,
        'Other' => 51,
        'Lung infiltrates' => 52
      }
    }
  end

  def get_sections(extraction)
    sections_hash = extraction.extractions_extraction_forms_projects_sections.index_by(&:section_name)
    design_section = sections_hash["Design Details"]
    index_section = sections_hash["Indexing Fields"]
    return design_section, index_section
  end

  def get_ref_code_2847(design_section, index_section)
    ref_codes = []
    attributes_mapping = get_attributes_id_mapping()

    index_eefpsqrcfs = index_section.extractions_extraction_forms_projects_sections_question_row_column_fields
    index_eefpsqrcfs.each do |eefpsqrcf|
      question_row_column = eefpsqrcf.question_row_column_field.question_row_column
      next unless question_row_column.question_row_column_type.id == 5

      value = eefpsqrcf.records[0]['name']
      next if value.blank?

      question_row = question_row_column.question_row
      question_row_name = question_row.name
      question_name = question_row.question.name
      value.scan(/\D*(\d+)\D*/).each do |match|
        checkbox_id = match[0].to_i

        checkbox = question_row_column.question_row_columns_question_row_column_options.find_by(id: checkbox_id)
        next if checkbox.nil?

        checkbox_name = checkbox['name'].strip.gsub(/\s+/, ' ')
        if checkbox_name == 'Other'
          if question_name == 'Article Purpose'
            ref_codes << attributes_mapping['article_purposes'][checkbox_name]
          elsif question_name == 'Exposure Measurement'
            ref_codes << attributes_mapping['exposure_measurements'][checkbox_name]
          elsif question_name == 'Outcomes: Measurement'
            ref_codes << attributes_mapping['outcomes_measurements'][checkbox_name]
          elsif question_name == 'Diseases or Diagnoses Reported'
            if question_row_name == 'Interstitial Lung Diseasess'
              ref_codes << attributes_mapping['interstitial_lung_diseasess'][checkbox_name]
            elsif question_row_name == 'Respiratory Tract Infections'
              ref_codes << attributes_mapping['respiratory_tract_infections'][checkbox_name]
            elsif question_row_name == 'Other Respiratory Disease'
              ref_codes << attributes_mapping['other_respiratory_diseases'][checkbox_name]
            end
          end
        elsif attributes_mapping['article_purposes'].key?(checkbox_name)
          ref_codes << attributes_mapping['article_purposes'][checkbox_name]
        elsif attributes_mapping['exposure_measurements'].key?(checkbox_name)
          ref_codes << attributes_mapping['exposure_measurements'][checkbox_name]
        elsif attributes_mapping['outcomes_measurements'].key?(checkbox_name)
          ref_codes << attributes_mapping['outcomes_measurements'][checkbox_name]
        elsif attributes_mapping['conflict_periods'].key?(checkbox_name)
          ref_codes << attributes_mapping['conflict_periods'][checkbox_name]
        elsif attributes_mapping['airway_inflammation_thickening'].key?(checkbox_name)
          ref_codes << attributes_mapping['airway_inflammation_thickening'][checkbox_name]
        elsif attributes_mapping['interstitial_lung_diseasess'].key?(checkbox_name)
          ref_codes << attributes_mapping['interstitial_lung_diseasess'][checkbox_name]
        elsif attributes_mapping['obstructive_lung_diseases'].key?(checkbox_name)
          ref_codes << attributes_mapping['obstructive_lung_diseases'][checkbox_name]
        elsif attributes_mapping['respiratory_tract_infections'].key?(checkbox_name)
          ref_codes << attributes_mapping['respiratory_tract_infections'][checkbox_name]
        elsif attributes_mapping['other_respiratory_diseases'].key?(checkbox_name)
          ref_codes << attributes_mapping['other_respiratory_diseases'][checkbox_name]
        end
      end
    end

    design_eefpsqrcfs = design_section.extractions_extraction_forms_projects_sections_question_row_column_fields
    design_eefpsqrcfs.each do |eefpsqrcf|
      question_row_column = eefpsqrcf.question_row_column_field.question_row_column
      next unless question_row_column.question_row_column_type.id == 5

      value = eefpsqrcf.records[0]['name']
      next if value.blank?

      question_name = question_row_column.question_row.question.name
      value.scan(/\D*(\d+)\D*/).each do |match|
        checkbox_id = match[0].to_i

        checkbox = question_row_column.question_row_columns_question_row_column_options.find_by(id: checkbox_id)
        next if checkbox.nil?

        checkbox_name = checkbox['name'].strip.gsub(/\s+/, ' ')
        if attributes_mapping['designs'].key?(checkbox_name)
          ref_codes << attributes_mapping['designs'][checkbox_name]
        elsif checkbox_name == 'Other'
          if question_name == 'Study Design'
            followups = get_followups(design_section)
            if followups[checkbox_id]
              ref_codes << followups[checkbox_id]['name']
            end
          end
        end
      end
    end
    return ref_codes
  end

  def get_followups(raw)
    followups = raw.extractions_extraction_forms_projects_sections_followup_fields.each_with_object({}) do |followup, hash|
      unless followup.records[0]['name'].blank?
        question_id = FollowupField.find(followup.followup_field_id).question_row_columns_question_row_column_option_id
        hash[question_id] = { 'name' => followup.records[0]['name'], 'id' => followup.followup_field_id }
      end
    end
  end

  def update_ref_codes_and_attributes(attributes, refs)
    current_id = 1001

    refs.each do |hash|
      hash['Codes'].each do |element|
        if element.is_a?(String) && !attributes['designs'].key?(element.strip)
          attributes['designs'][element.strip] = current_id
          current_id += 1
        end
      end
    end

    updated_refs = refs.map do |hash|
      updated_codes = hash['Codes'].map do |element|
        element.is_a?(String) ? attributes['designs'][element.strip] : element
      end
      hash.merge('Codes' => updated_codes)
    end

    [attributes, updated_refs]
  end

  def transform_attributes(original_attributes)
    transformed_attributes = {}

    original_attributes.each do |key, values|
      transformed_attributes[key] = values.map do |name, id|
        {
          'AttributeId' => id,
          'AttributeType' => 'Selectable (show checkbox)',
          'AttributeName' => name
        }
      end
    end

    return transformed_attributes
  end

  def get_layered_attributes(attributes)
    layered_attributes = {
      'AttributesList' => [
        {
          'AttributeId' => 2001,
          'AttributeType' => 'Selectable (show checkbox)',
          'AttributeName' => 'Article Characteristics',
          'Attributes' => {
            'AttributesList' => [
              {
                'AttributeId' => 2004,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Article Purpose',
                'Attributes' => {
                  'AttributesList' => attributes['article_purposes']
                }
              },
              {
                'AttributeId' => 2005,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Exposure Measurement',
                'Attributes' => {
                  'AttributesList' => attributes['exposure_measurements']
                }
              },
              {
                'AttributeId' => 2006,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Outcomes: Measurement',
                'Attributes' => {
                  'AttributesList' => attributes['outcomes_measurements']
                }
              },
              {
                'AttributeId' => 2007,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Conflict Period(s)',
                'Attributes' => {
                  'AttributesList' => attributes['conflict_periods']
                }
              }
            ]
          }
        },
        {
          'AttributeId' => 2002,
          'AttributeType' => 'Selectable (show checkbox)',
          'AttributeName' => 'Diseases or Diagnoses Reported',
          'Attributes' => {
            'AttributesList' => [
              {
                'AttributeId' => 2008,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Airway inflammation/thickening',
                'Attributes' => {
                  'AttributesList' => attributes['airway_inflammation_thickening']
                }
              },
              {
                'AttributeId' => 2009,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Interstitial Lung Diseasess',
                'Attributes' => {
                  'AttributesList' => attributes['interstitial_lung_diseasess']
                }
              },
              {
                'AttributeId' => 2010,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Obstructive Lung Diseases',
                'Attributes' => {
                  'AttributesList' => attributes['obstructive_lung_diseases']
                }
              },
              {
                'AttributeId' => 2011,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Respiratory Tract Infections',
                'Attributes' => {
                  'AttributesList' => attributes['respiratory_tract_infections']
                }
              },
              {
                'AttributeId' => 2012,
                'AttributeType' => 'Selectable (show checkbox)',
                'AttributeName' => 'Other Respiratory Disease',
                'Attributes' => {
                  'AttributesList' => attributes['other_respiratory_diseases']
                }
              }
            ]
          }
        },
        {
          'AttributeId' => 2003,
          'AttributeType' => 'Selectable (show checkbox)',
          'AttributeName' => 'Study Design',
          'Attributes' => {
            'AttributesList' => attributes['designs']
          }
        }
      ]
    }
    return layered_attributes
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

  def get_reference_2847(extraction, codes)
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
    return reference
  end

  def transform_codes(refs)
    refs.map do |ref|
      transformed_codes = ref['Codes'].map do |code|
        {
          'AttributeId' => code,
          'ItemAttributeFullTextDetails' => []
        }
      end
      ref.merge('Codes' => transformed_codes)
    end
  end
end
