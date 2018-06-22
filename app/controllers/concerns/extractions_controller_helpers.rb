module ExtractionsControllerHelpers
  extend ActiveSupport::Concern

  included do

    # Params: ENUMERABLE[ExtractionFormsProjects], ENUMERABLE[Extractions]
    #
    # Returns: HASH
    #
    # Creates a hash of hashes that does a head to head comparison between
    # the extractions and their data.
    # {19=>
    #  {:extraction_forms_project_id=>19,
    #   145=>{:extraction_forms_projects_section_id=>145},
    #   146=>
    #  {:extraction_forms_projects_section_id=>146,
    #   :section_name=>"Arms",
    #   :type1s=>
    #  [#<Type1:0x007ff8a3bcf798
    #   id: 9,
    #   name: "I can get some",
    #   description: "Beer",
    #   deleted_at: nil,
    #   created_at: Thu, 14 Jun 2018 04:47:30 UTC +00:00,
    #   updated_at: Thu, 14 Jun 2018 04:48:04 UTC +00:00>,
    #   #<Type1:0x007ff8a3bcf658
    #   id: 10,
    #   name: "Or do I?",
    #   description: "",
    #   deleted_at: nil,
    #   created_at: Thu, 14 Jun 2018 04:49:31 UTC +00:00,
    #   updated_at: Thu, 14 Jun 2018 04:49:31 UTC +00:00>,
    #   #<Type1:0x007ff8a3bcf450
    #   id: 12,
    #   name: "DELETE ME!",
    #   description: "",
    #   deleted_at: nil,
    #   created_at: Mon, 18 Jun 2018 08:11:07 UTC +00:00,
    #   updated_at: Mon, 18 Jun 2018 08:11:07 UTC +00:00>]},
    #   147=>{:extraction_forms_projects_section_id=>147},
    #   148=>{:extraction_forms_projects_section_id=>148},
    #   149=>
    #   {:extraction_forms_projects_section_id=>149,
    #    :section_name=>"Outcomes",
    #    :type1s=>
    #   [#<Type1:0x007ff899ba8e40
    #    id: 4,
    #    name: "Pain",
    #    description: "mild",
    #    deleted_at: nil,
    #    created_at: Tue, 12 Jun 2018 10:59:24 UTC +00:00,
    #    updated_at: Tue, 12 Jun 2018 10:59:24 UTC +00:00>]},
    #    150=>{:extraction_forms_projects_section_id=>150},
    #    151=>{:extraction_forms_projects_section_id=>151},
    #    152=>{:extraction_forms_projects_section_id=>152}}}
    #
    #    The point here is to discover master lists for each of the following:
    #      1. All type1 for every extraction within this citation group.
    #      2. All populations per type1.
    #      3. All timetpoints per population.
    def head_to_head(extraction_forms_projects, extractions)
      return_value = Hash.new

      extraction_forms_projects.each do |efp|
        efp_id = efp.id
        return_value[efp_id] = Hash.new
        return_value[efp_id][:extraction_forms_project_id] = efp_id
        efp.extraction_forms_projects_sections.each do |efps|
          efps_id = efps.id
          return_value[efp_id][efps_id] = Hash.new
          return_value[efp_id][efps_id][:extraction_forms_projects_section_id] = efps_id
          case efps.extraction_forms_projects_section_type_id
          when 1
            return_value[efp_id][efps_id][:section_name] = efps.section.name

            # Find all eefpss across all extractions for this (type1) section
            eefpss = ExtractionsExtractionFormsProjectsSection.where(
              extraction: extractions,
              extraction_forms_projects_section: efps)

            # This finds all eefpst1s across all extractions for this (type1) section.
            eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1.
              where(extractions_extraction_forms_projects_section: eefpss)

            # Keep a master list of all type1s across all extractions for this section.
            return_value[efp_id][efps_id][:all_type1s_across_extractions] = eefpst1s.map(&:type1).to_set

            # Iterate over each eefps to find master lists for each eefpst1 separately.
            eefpss.each do |eefps|
              eefps_id = eefps.id
              return_value[efp_id][efps_id][eefps_id] = Hash.new
              return_value[efp_id][efps_id][eefps_id][:extraction_id] = eefps.extraction.id
              return_value[efp_id][efps_id][eefps_id][:extractions_extraction_forms_projects_section_id] = eefps_id

              # Iterate over eefpst1s to find master lists of populations for a specific type1.
              eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
                eefpst1_type1_id = eefpst1.type1.id

                # This will collect all populations for a specific type1. Don't recreate if one already exists.
                return_value[efp_id][efps_id][:all_population_names_across_type1]                    = Hash.new unless return_value[efp_id][efps_id].has_key? :all_population_names_across_type1
                return_value[efp_id][efps_id][:all_population_names_across_type1][eefpst1_type1_id]  = Set.new  unless return_value[efp_id][efps_id][:all_population_names_across_type1].has_key? eefpst1_type1_id

                eefpst1_id = eefpst1.id
                return_value[efp_id][efps_id][eefps_id][eefpst1_id] = Hash.new
                return_value[efp_id][efps_id][eefps_id][eefpst1_id][:extractions_extraction_forms_projects_sections_type1_id] = eefpst1_id

                # Find all populations across extractions for this particular type1.
                eefpst1rs = ExtractionsExtractionFormsProjectsSectionsType1Row.
                  joins(extractions_extraction_forms_projects_sections_type1: [:type1, { extractions_extraction_forms_projects_section: :extraction }]).
                  where(extractions_extraction_forms_projects_sections_type1s: { type1: eefpst1.type1 }).
                  where(extractions_extraction_forms_projects_sections_type1s: { extractions_extraction_forms_projects_sections: { extraction: extractions } })

                # Keep a master list of all populations across all extractions for this type1.
                return_value[efp_id][efps_id][:all_population_names_across_type1][eefpst1_type1_id].merge eefpst1rs.map(&:population_name).to_set

#                # Iterate over eefpst1rs to find master list of timepoints.
#                eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
#                  eefpst1r_id = eefpst1r.id
#                  eefpst1r_population_name_id = eefpst1r.population_name.id
#
#                  # This will collect all timepoints for a specific population. Don't recreate if one already exists.
#                  return_value[efp_id][efps_id][:all_timepoint_names_across_population]                               = Hash.new unless return_value[efp_id][efps_id].has_key? :all_timepoint_names_across_population
#                  return_value[efp_id][efps_id][:all_timepoint_names_across_population][eefpst1r_population_name_id]  = Set.new  unless return_value[efp_id][efps_id][:all_timepoint_names_across_population].has_key? eefpst1r_population_name_id
#
#                  # Find all timepoints across all extractions for this population.
#                  eefpst1rcs = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.
#                    joins(extractions_extraction_forms_projects_sections_type1_row: [:population_name, { extractions_extraction_forms_projects_sections_type1: { extractions_extraction_forms_projects_section: :extraction } }]).
#                    where(extractions_extraction_forms_projects_sections_type1_rows: { population_name: eefpst1r.population_name }).
#                    where(extractions_extraction_forms_projects_sections_type1_rows: { extractions_extraction_forms_projects_sections_type1s: { extractions_extraction_forms_projects_sections: { extraction: extractions } } })
#
#                  # Keep a master list of all timepoints across all extractions for this population.
#                  return_value[efp_id][efps_id][:all_timepoint_names_across_population][eefpst1r_population_name_id].merge eefpst1rcs.map(&:timepoint_name).to_set
#                end
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
