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

        unless return_value.has_key?(efp_id)
          return_value[efp_id] = Hash.new
          return_value[efp_id][:extraction_forms_project_id] = efp_id
          return_value[efp_id][:efpss] = Hash.new
        end

        efp.extraction_forms_projects_sections.each do |efps|
          efps_id = efps.id

          unless return_value[efp_id][:efpss].has_key?(efps_id)
            return_value[efp_id][:efpss][efps_id] = Hash.new
#            return_value[efp_id][:efpss][efps_id][:extraction_forms_projects_section_id] = efps_id
#            return_value[efp_id][:efpss][efps_id][:eefpss] = Hash.new
            return_value[efp_id][:efpss][efps_id][:type1s] = Hash.new
            return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s] = Hash.new
          end

          case efps.extraction_forms_projects_section_type_id
          when 1
            return_value[efp_id][:efpss][efps_id][:section_name] = efps.section.name

            # Find all eefpss across all extractions for this section
#            eefpss = ExtractionsExtractionFormsProjectsSection.where(
#              extraction: extractions,
#              extraction_forms_projects_section: efps)
            eefpss = efps.extractions_extraction_forms_projects_sections.
              where(extraction: extractions)

            # Find all eefpst1s across all extractions for this section.
            eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1.
              includes(:type1).
              where(extractions_extraction_forms_projects_section: eefpss)

            # Keep a master list of all type1s across all extractions for this section.
            return_value[efp_id][:efpss][efps_id][:all_type1s_across_extractions] = eefpst1s.map(&:type1).to_set

            # Iterate over each eefps to find master lists for each eefpst1 separately.
            eefpss.each do |eefps|
              eefps_id = eefps.id

#              unless return_value[efp_id][:efpss][efps_id][:eefpss].has_key?(eefps_id)
#                return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id] = Hash.new
#                return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:extractions_extraction_forms_projects_section_id] = eefps_id
#                return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s] = Hash.new
#              end

              # Iterate over eefpst1s to find master lists of populations for a specific type1.
              eefps.extractions_extraction_forms_projects_sections_type1s.includes(:type1, :extractions_extraction_forms_projects_sections_type1_rows).each do |eefpst1|
                eefpst1_id = eefpst1.id

                # Keep track of how often a type1 is present.
                return_value[efp_id][:efpss][efps_id][:type1s][eefpst1.type1.id] = Array.new unless return_value[efp_id][:efpss][efps_id][:type1s].has_key?(eefpst1.type1.id)
                return_value[efp_id][:efpss][efps_id][:type1s][eefpst1.type1.id] << eefpst1

#                unless return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s].has_key?(eefpst1_id)
#                  return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id] = Hash.new
#                  return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:extractions_extraction_forms_projects_sections_type1_id] = eefpst1_id
#                  return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs] = Hash.new
#                end

                # Find all eefpst1rs across extractions for this particular type1.
#                eefpst1rs = ExtractionsExtractionFormsProjectsSectionsType1Row.
#                  includes(:population_name).
#                  joins(extractions_extraction_forms_projects_sections_type1: [:type1, { extractions_extraction_forms_projects_section: :extraction }]).
#                  where(extractions_extraction_forms_projects_sections_type1s: { type1: eefpst1.type1 }).
#                  where(extractions_extraction_forms_projects_sections_type1s: { extractions_extraction_forms_projects_sections: { extraction: extractions } })
                eefpst1rs = eefpst1.extractions_extraction_forms_projects_sections_type1_rows.
                  includes(:population_name).
                  joins(extractions_extraction_forms_projects_sections_type1: [:type1, { extractions_extraction_forms_projects_section: :extraction }]).
                  where(extractions_extraction_forms_projects_sections_type1s: { extractions_extraction_forms_projects_sections: { extraction: extractions } })

                # Keep a master list of all population_names across all extractions for this type1.
                unless return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s].has_key?(eefpst1.type1.id)
                  return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id] = Hash.new
                  return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id][:all_timepoints_across_populations] = Hash.new
                end
                return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id][:population_names] = eefpst1rs.map(&:population_name).to_set

                eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
                  eefpst1r_id = eefpst1r.id

                  # Keep track of how often a population is present.
                  return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id][:populations] = Hash.new unless return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id].has_key?(:populations)
                  return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id][:populations][eefpst1r.population_name.id] = Array.new unless return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id][:populations].has_key?(eefpst1r.population_name.id)
                  return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1.type1.id][:populations][eefpst1r.population_name.id] << eefpst1r

#                  unless return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs].has_key?(eefpst1r_id)
#                    return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs][eefpst1r_id] = Hash.new
#                    return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs][eefpst1r_id][:extractions_extraction_forms_projects_sections_type1_row_id] = eefpst1r_id
#                    return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs][eefpst1r_id][:eefpst1rcs] = Hash.new
#                  end

                  # Find all eefpst1rcs across extractions for this particular population.
#                  eefpst1rcs = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.
#                    includes(:timepoint_name).
#                    joins(extractions_extraction_forms_projects_sections_type1_row: [:population_name, { extractions_extraction_forms_projects_sections_type1: [:type1, { extractions_extraction_forms_projects_section: :extraction }] }]).
#                    where(extractions_extraction_forms_projects_sections_type1_rows: { population_name: eefpst1r.population_name }).
#                    where(extractions_extraction_forms_projects_sections_type1_rows: { extractions_extraction_forms_projects_sections_type1s: { type1: eefpst1r.extractions_extraction_forms_projects_sections_type1.type1 } }).
#                    where(extractions_extraction_forms_projects_sections_type1_rows: { extractions_extraction_forms_projects_sections_type1s: { extractions_extraction_forms_projects_sections: { extraction: extractions } } })
                  eefpst1rcs = eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.
                    includes(:timepoint_name).
                    joins(extractions_extraction_forms_projects_sections_type1_row: [:population_name, { extractions_extraction_forms_projects_sections_type1: [:type1, { extractions_extraction_forms_projects_section: :extraction }] }]).
                    where(extractions_extraction_forms_projects_sections_type1_rows: { extractions_extraction_forms_projects_sections_type1s: { type1: eefpst1r.extractions_extraction_forms_projects_sections_type1.type1 } }).
                    where(extractions_extraction_forms_projects_sections_type1_rows: { extractions_extraction_forms_projects_sections_type1s: { extractions_extraction_forms_projects_sections: { extraction: extractions } } })

                  # Keep a master list of all timepoint_names across all extractions for this population.
                  unless return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1r.extractions_extraction_forms_projects_sections_type1.type1.id][:all_timepoints_across_populations].has_key?(eefpst1r.population_name.id)
                    return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1r.extractions_extraction_forms_projects_sections_type1.type1.id][:all_timepoints_across_populations][eefpst1r.population_name.id] = Hash.new
                  end
                  return_value[efp_id][:efpss][efps_id][:all_populations_across_type1s][eefpst1r.extractions_extraction_forms_projects_sections_type1.type1.id][:all_timepoints_across_populations][eefpst1r.population_name.id][:timepoint_names] = eefpst1rcs.map(&:timepoint_name).to_set

                  eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
                    eefpst1rc_id = eefpst1rc.id
#
#                    unless return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs][eefpst1r_id][:eefpst1rcs].has_key?(eefpst1rc_id)
#                      return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs][eefpst1r_id][:eefpst1rcs][eefpst1rc_id] = Hash.new
#                      return_value[efp_id][:efpss][efps_id][:eefpss][eefps_id][:eefpst1s][eefpst1_id][:eefpst1rs][eefpst1r_id][:eefpst1rcs][eefpst1rc_id][:extractions_extraction_forms_projects_sections_type1_row_column_id] = eefpst1rc_id
#                    end
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
