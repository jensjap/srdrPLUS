module ExtractionsControllerHelpers
  extend ActiveSupport::Concern

  included do

    # Params: ENUMERABLE[ExtractionFormsProjects], ENUMERABLE[Extractions]
    #
    # Returns: HASH
    #
    # Creates a hash of hashes that does a head to head comparison between
    # the extractions and their data.
    def head_to_head(extraction_forms_projects, extractions)
      return_value = Hash.new

      extraction_forms_projects.each do |efp|
        efp_id = efp.id

        return_value[efp_id] ||= {}
        return_value[efp_id][:name] = :extraction_forms_project
        return_value[efp_id][:id] = efp_id

        efp.extraction_forms_projects_sections.each do |efps|
          efps_id = efps.id

          case efps.extraction_forms_projects_section_type_id
          when 1
            return_value[efp_id][efps_id] ||= {}
            return_value[efp_id][efps_id][:name] ||= :extraction_forms_projects_section
            return_value[efp_id][efps_id][:id] ||= efps_id
            return_value[efp_id][efps_id][:all_type1s] = ExtractionsExtractionFormsProjectsSectionsType1
              .includes(:type1)
              .where(extractions_extraction_forms_projects_section: efps.extractions_extraction_forms_projects_sections
              .where(extraction: extractions))
              .order(id: :asc)
              .map(&:type1).to_set

            extractions.each do |extraction|
              eefps = efps.extractions_extraction_forms_projects_sections
                .where(extraction: extraction)
              raise RuntimeError, 'More than one ExtractionsExtractionFormsProjectsSection found.' unless eefps.length.eql?(1)
              eefps.first.extractions_extraction_forms_projects_sections_type1s.includes(:type1).each do |eefpst1|
                type1_id = eefpst1.type1.id
                return_value[efp_id][efps_id][type1_id] ||= {}
                return_value[efp_id][efps_id][type1_id][:name] ||= :type1
                return_value[efp_id][efps_id][type1_id][:id] ||= type1_id
                return_value[efp_id][efps_id][type1_id][:eefpst1s] ||= []
                return_value[efp_id][efps_id][type1_id][:eefpst1s] << eefpst1.id

                eefpst1.extractions_extraction_forms_projects_sections_type1_rows.includes(:population_name).each do |eefpst1r|
                  population_name_id = eefpst1r.population_name.id
                  return_value[efp_id][efps_id][type1_id][:unique_population_names] ||= Set.new
                  return_value[efp_id][efps_id][type1_id][:unique_population_names].add(eefpst1r.population_name)
                  return_value[efp_id][efps_id][type1_id][:population_names] ||= {}
                  return_value[efp_id][efps_id][type1_id][:population_names][population_name_id] ||= {}
                  return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:name] ||= :population_name
                  return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:id] ||= population_name_id
                  return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:eefpst1rs] ||= []
                  return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:eefpst1rs] << eefpst1r.id

                  eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.includes(:timepoint_name).each do |eefpst1rc|
                    timepoint_name_id = eefpst1rc.timepoint_name.id
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:unique_timepoint_names] ||= Set.new
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:unique_timepoint_names].add(eefpst1rc.timepoint_name)
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:timepoint_names] ||= {}
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:timepoint_names][timepoint_name_id] ||= {}
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:timepoint_names][timepoint_name_id][:name] ||= :timepoint_name
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:timepoint_names][timepoint_name_id][:id] ||= timepoint_name_id
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:timepoint_names][timepoint_name_id][:eefpst1rcs] ||= []
                    return_value[efp_id][efps_id][type1_id][:population_names][population_name_id][:timepoint_names][timepoint_name_id][:eefpst1rcs] << eefpst1rc.id
                  end
                end
              end
            end
          when 2
          when 3
          else
            raise RuntimeError, 'Unknown ExtractionFormsProjectsSectionType'
          end
        end
      end

      return return_value
    end
  end

  class_methods do
  end
end
