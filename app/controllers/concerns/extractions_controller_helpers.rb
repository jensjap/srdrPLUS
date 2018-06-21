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
            eefpss = ExtractionsExtractionFormsProjectsSection.where(
              extraction: extractions,
              extraction_forms_projects_section: efps)
            eefpst1s =
              ExtractionsExtractionFormsProjectsSectionsType1.
              where(extractions_extraction_forms_projects_section: eefpss)
            eefpst1rs =
              ExtractionsExtractionFormsProjectsSectionsType1Row.
              where(extractions_extraction_forms_projects_sections_type1: eefpst1s)
            eefpst1rcs =
              ExtractionsExtractionFormsProjectsSectionsType1RowColumn.
              where(extractions_extraction_forms_projects_sections_type1_row: eefpst1rs)

            # Complete list of unique type1s for this citation_group.
            return_value[efp_id][efps_id][:type1s]           = eefpst1s.map(&:type1).to_set
            return_value[efp_id][efps_id][:population_names] = eefpst1rs.map(&:population_name).to_set
            return_value[efp_id][efps_id][:timepoint_names]  = eefpst1rcs.map(&:timepoint_name).to_set
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
