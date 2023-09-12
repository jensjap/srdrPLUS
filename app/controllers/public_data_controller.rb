class PublicDataController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope, :set_record, only: [:show]
  skip_before_action :authenticate_user!

  def show
    if @project&.public?
      render @template
    else
      path_error_page = Rails.public_path.join('404.html')
      send_file path_error_page, disposition: 'inline', content_type: 'text/html'
    end
  end

  private
    def set_record
      id = params[:id]

      case params[:type]
      when 'project'
        @project = Project.find(id)
        @template = '/public_data/project'
      when 'extraction_form'
        @efp = ExtractionFormsProject.find(id)
        @project = @efp.project
        @template = '/public_data/extraction_form'
      when 'extraction'
        @extraction = Extraction.find(id)
        update_record_helper_dictionaries(@extraction)
        @project = @extraction.project
        @extraction_forms_projects = @project.extraction_forms_projects.includes(:extraction_form)


        if @extraction_forms_projects.first.extraction_forms_project_type.name.eql? ExtractionFormsProjectType::DIAGNOSTIC_TEST
          @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
            .by_section_name_and_extraction_id_and_extraction_forms_project_id('Diagnoses',
                                                                              @extraction.id,
                                                                              @extraction_forms_projects.first.id)
        else
          @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
            .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                              @extraction.id,
                                                                              @extraction_forms_projects.first.id)
        end

        # If a specific 'Outcome' is requested we load it here.
        if params[:eefpst1_id].present?
          @eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id])
        # Otherwise we choose the first 'Outcome' in the extraction to display.
        else
          @eefpst1 = @eefpst1s.first
        end


        @eefps_by_efps_dict ||= @extraction.extractions_extraction_forms_projects_sections.group_by(&:extraction_forms_projects_section_id)
        @template = '/public_data/extraction'
      end
    end

    def update_record_helper_dictionaries(extraction)
      @eefps_qrcf_dict ||= {}
      @records_dict ||= {}
      extraction.extractions_extraction_forms_projects_sections.each do |eefps|
        eefps.
        extractions_extraction_forms_projects_sections_question_row_column_fields.
        includes([
          :records,
          :extractions_extraction_forms_projects_sections_type1
        ]).each do |eefps_qrcf|
          @eefps_qrcf_dict[[eefps.id,eefps_qrcf.question_row_column_field_id,eefps_qrcf.extractions_extraction_forms_projects_sections_type1&.type1_id].to_s] = eefps_qrcf
          if eefps_qrcf.records.blank?
            @records_dict[eefps_qrcf.id] = Record.find_or_create_by(recordable: eefps_qrcf)
          else
            @records_dict[eefps_qrcf.id] = eefps_qrcf.records.first
          end
        end
      end
    end
end
