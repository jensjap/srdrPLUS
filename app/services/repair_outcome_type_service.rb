# frozen_string_literal: true

# Repairs extracted outcomes without outcome type.
#
# Possible options for type1_type for Outcomes should be:
# ['Continuous' ,'Categorical']
class RepairOutcomeTypeService
  def self.repair!(project_id = nil, only_count: true)
    # Project ID 2847 'VA Airborne Hazards Constrictive Bronchiolitis and Interstitial Lung Diseases'
    project_id = 2847 if project_id.blank?

    candidates = find_candidates_for_repair(project_id)
    puts "#{candidates.count} need repair"
    unless only_count
      candidates.each do |candidate|
        repair_outcome_type(candidate)
      end
    end

    puts 'done.'
  end

  # Attempt to repair based on other outcomes.
  def self.repair_outcome_type(eefpst1)
    template = find_template_for_repair(eefpst1)
    if template.present?
      puts 'Found suitable template!!'
      puts "Applying fix using type: \"#{template.type1_type.name}\""
      puts '==========================================================='
      eefpst1.update(type1_type: template.type1_type)
    else
      puts 'No suitable template found =('
      puts 'Applying fix using default type: "Categorical"'
      puts '==========================================================='
      eefpst1.update(type1_type: Type1Type.find_by(name: 'Categorical'))
    end
  end

  # Look for other eefpst1 and use as template.
  # Conditions:
  # 1. (optional) Be in the same project
  # 1. Must have same type1.name and type1.description
  # 1. Must have a type1_type
  # Match the type1_type of the first one found
  def self.find_template_for_repair(eefpst1)
    potential_templates = query_for_template_candidates(eefpst1, local_only: true)
    potential_templates = query_for_template_candidates(eefpst1, local_only: false) if potential_templates.blank?

    potential_templates&.first
  end

  def self.query_for_template_candidates(eefpst1, local_only: true)
    if local_only
      puts '..Looking locally'
      ExtractionsExtractionFormsProjectsSectionsType1
        .joins(:type1, extractions_extraction_forms_projects_section:
          [{ extraction_forms_projects_section: :section },
           { extraction: :project }])
        .where('projects.id=?', eefpst1.extraction.project.id)
        .where('type1s.name=? AND type1s.description=?', eefpst1.type1.name, eefpst1.type1.description)
        .where('sections.name=?', 'Outcomes')
        .where.not(type1_type: nil)
    else
      puts '..Looking globally'
      ExtractionsExtractionFormsProjectsSectionsType1
        .joins(:type1, extractions_extraction_forms_projects_section:
          [{ extraction_forms_projects_section: :section },
           { extraction: :project }])
        .where('type1s.name=? AND type1s.description=?', eefpst1.type1.name, eefpst1.type1.description)
        .where('sections.name=?', 'Outcomes')
        .where.not(type1_type: nil)
    end
  end

  def self.find_candidates_for_repair(project_id = nil)
    candidates = ExtractionsExtractionFormsProjectsSectionsType1
                 .joins(
                   extractions_extraction_forms_projects_section: [
                     { extraction_forms_projects_section: :section },
                     { extraction: :project }
                   ]
                 )
                 .where('sections.name=? AND type1_type_id IS NULL', 'Outcomes')
    candidates = candidates.where('projects.id=?', project_id) if project_id
    candidates
  end
end
