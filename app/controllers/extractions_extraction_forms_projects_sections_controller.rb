class ExtractionsExtractionFormsProjectsSectionsController < ApplicationController
  before_action :set_extractions_extraction_forms_projects_section, :skip_policy_scope, only: [:update]

  # PATCH/PUT /extractions_extraction_forms_projects_sections/1
  # PATCH/PUT /extractions_extraction_forms_projects_sections/1.json
  def update
    authorize(@extractions_extraction_forms_projects_section.project, policy_class: ExtractionsExtractionFormsProjectsSectionPolicy)
    respond_to do |format|
      if @extractions_extraction_forms_projects_section.update(extractions_extraction_forms_projects_section_params)
        format.html do
          if params[:extractions_extraction_forms_projects_section].has_key? :extraction_ids
            redirect_to consolidate_project_extractions_path(@extractions_extraction_forms_projects_section.project,
              extraction_ids: params[:extractions_extraction_forms_projects_section][:extraction_ids],
              'panel-tab': @extractions_extraction_forms_projects_section.extraction_forms_projects_section.id.to_s),
              notice: t('success')
          else
            redirect_to work_extraction_path(
              @extractions_extraction_forms_projects_section.extraction,
              "panel-tab": @extractions_extraction_forms_projects_section.extraction_forms_projects_section.id.to_s),
              notice: t('success')
          end
        end
        format.json {
          render :show, status: :ok, location: @extractions_extraction_forms_projects_section
        }
        format.js do
          if params[:extractions_extraction_forms_projects_section][:action] == 'work'
            @consolidated_extraction = @extractions_extraction_forms_projects_section.extraction
            render '/extractions_extraction_forms_projects_sections/work_update'
          else
            @action                = params[:extractions_extraction_forms_projects_section][:action]
            @extraction            = @extractions_extraction_forms_projects_section.extraction
            @linked_type2_sections = @extractions_extraction_forms_projects_section.link_to_type2s
            @results_eefps         = @extraction.find_eefps_by_section_type('Results')
          end
        end
      else
        format.html {
          redirect_to work_extraction_path(
            @extractions_extraction_forms_projects_section.extraction,
            "panel-tab": @extractions_extraction_forms_projects_section.extraction_forms_projects_section.id.to_s
          ),
          alert: t('failure')
        }
        format.json {
          render json: @extractions_extraction_forms_projects_section.errors, status: :unprocessable_entity
        }
        format.js do
        end
      end
    end
  end

#  def update_status
#    if not ["Draft", "Completed"].include? extractions_extraction_forms_projects_section_params[:statusing_attributes][:status_attributes][:name]
#      return
#    end
#    if @extractions_extraction_forms_projects_section.statusing.nil?
#    @extractions_extraction_forms_projects_section.statusing
#  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extractions_extraction_forms_projects_section
      @extractions_extraction_forms_projects_section = ExtractionsExtractionFormsProjectsSection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extractions_extraction_forms_projects_section_params
      params.require(:extractions_extraction_forms_projects_section)
        .permit(:extraction_id,
                :extraction_forms_projects_section_id,
                { status_attributes: [:name] } ,
                extractions_extraction_forms_projects_sections_type1s_attributes: [:type1_type_id, :units, type1_attributes: [:id, :name, :description], extractions_extraction_forms_projects_sections_type1_rows_attributes: [:_destroy, population_name_attributes: [:name, :description ], extractions_extraction_forms_projects_sections_type1_row_columns_attributes: [:_destroy, :extractions_extraction_forms_projects_sections_type1_row_id, timepoint_name_attributes: [:name, :unit]]]])
    end
end
