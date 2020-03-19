class ResultStatisticSectionsController < ApplicationController

  add_breadcrumb 'my projects', :projects_path

  before_action :set_result_statistic_section, only: [:edit, :update, :add_comparison, :consolidate]
  before_action :set_arms, only: [:edit, :update, :add_comparison, :consolidate]
  before_action :set_extractions, only: [:consolidate]
  #!!! Birol: don't think this is working...where is comparables set?
  #before_action :set_comparisons_measures, only: [:edit]

  before_action :skip_policy_scope

  # GET /result_statistic_sections/1/edit
  def edit
    add_breadcrumb 'edit project', edit_project_path(@result_statistic_section.extraction.project)
    add_breadcrumb 'extractions',  project_extractions_path(@result_statistic_section.extraction.project)
    add_breadcrumb 'work',         work_extraction_path(@result_statistic_section.extraction,
                                                          params: { eefpst1_id: @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1_id },
                                                          anchor: "panel-tab-#{ @result_statistic_section.eefps_result.id }")
    add_breadcrumb @result_statistic_section.result_statistic_section_type.name.downcase,
      :edit_result_statistic_section_path
  end

  # PATCH/PUT /result_statistic_sections/1
  # PATCH/PUT /result_statistic_sections/1.json
  def update
    respond_to do |format|
      if @result_statistic_section.update(result_statistic_section_params)
        format.html { redirect_to edit_result_statistic_section_path(@result_statistic_section),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @result_statistic_section }
        format.js do
          @eefpst1 = @result_statistic_section
            .population
            .extractions_extraction_forms_projects_sections_type1
          @extraction                = @result_statistic_section.extraction
          @project                   = @result_statistic_section.project
          @extraction_forms_projects = @project.extraction_forms_projects
          @eefpst1s                  = ExtractionsExtractionFormsProjectsSectionsType1
            .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                               @extraction.id,
                                                                               @extraction_forms_projects.first.id)
        end
      else
        format.html { render :edit }
        format.json { render json: @result_statistic_section.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_comparison
    # This is required because in the NET Change section we have both types of comparisons; BAC and WAC. So in order to create the comparison
    # in the correct section we use a hidden form input :comparison_type.
    if params[:result_statistic_section]['comparison_type'] == 'bac'
      temp_result_statistic_section = @result_statistic_section.population.result_statistic_sections.find_by(result_statistic_section_type_id: 2)
    elsif params[:result_statistic_section]['comparison_type'] == 'wac'
      temp_result_statistic_section = @result_statistic_section.population.result_statistic_sections.find_by(result_statistic_section_type_id: 3)
    end

    respond_to do |format|
      if temp_result_statistic_section.update(result_statistic_section_params)
        format.html { redirect_to edit_result_statistic_section_path(@result_statistic_section),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @result_statistic_section }
        format.js do
          @eefpst1 = @result_statistic_section
            .population
            .extractions_extraction_forms_projects_sections_type1
          @extraction                = @result_statistic_section.extraction
          @project                   = @result_statistic_section.project
          @extraction_forms_projects = @project.extraction_forms_projects
          @eefpst1s                  = ExtractionsExtractionFormsProjectsSectionsType1
            .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                               @extraction.id,
                                                                               @extraction_forms_projects.first.id)
        end
      else
        format.html do
          flash[:alert] = 'Invalid comparison'
          render :edit
        end
        format.json { render json: @result_statistic_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /result_statistic_sections/1/consolidate
  def consolidate
    @project      = @result_statistic_section.extraction.project
    quadrant_name = @result_statistic_section.result_statistic_section_type.name

    add_breadcrumb 'edit project',    edit_project_path(@project)
    add_breadcrumb 'extractions',     project_extractions_path(@project)
    add_breadcrumb 'comparison tool', comparison_tool_project_extractions_path(@project)
    add_breadcrumb 'consolidate',
      consolidate_project_extractions_path(
        project_id: @project.id,
        extraction_ids: @extractions.map(&:id),
        params: { eefpst1_id: @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1_id },
        anchor: "panel-tab-#{ @result_statistic_section.eefps_result.id }")
    add_breadcrumb quadrant_name.downcase, consolidate_result_statistic_section_path(extraction_ids: @extractions.map(&:id))
  end

  def manage_measures
    respond_to do |format|
      format.js do
        @result_statistic_section = ResultStatisticSection.find(params[:rss_id])
        t1_type_id = @result_statistic_section
          .population
          .extractions_extraction_forms_projects_sections_type1
          .type1_type_id
        @options = @result_statistic_section
          .result_statistic_section_type
          .result_statistic_section_types_measures
          .where(type1_type_id: t1_type_id)
          .map do |rsstm|
          [rsstm.measure.name, rsstm.measure.id, @result_statistic_section.measures.include?(rsstm.measure) ? { 'data-selected' => '' } : '']
        end
      end
    end
  end

  private
#    # check if all the join table entries are in place, create if needed
#    def set_comparisons_measures
#      @result_statistic_section.measures.each do |measure|
#        @result_statistic_section.comparisons.each do |comparison|
#          unless @result_statistic_section.comparisons_measures.exists?( measure: measure, comparison: comparison)
#            @result_statistic_section.comparisons_measures.build( measure: measure, comparison: comparison )
#          end
#        end
#      end
#    end

    # Use callbacks to share common setup or constraints between actions.
    def set_arms
      @arms = ExtractionsExtractionFormsProjectsSectionsType1.by_section_name_and_extraction_id_and_extraction_forms_project_id('Arms',
      @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction.id,
      @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.extraction_forms_project.id)
    end

    def set_result_statistic_section
      @result_statistic_section = ResultStatisticSection
        .includes(population: { extractions_extraction_forms_projects_sections_type1: [ :type1, extractions_extraction_forms_projects_section: [ :extraction, extraction_forms_projects_section: :extraction_forms_project ] ] } )
        .includes(:result_statistic_section_type)
        .find(params[:id])
      authorize(@result_statistic_section.project, policy_class: ResultStatisticSectionPolicy)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def result_statistic_section_params
      params.require(:result_statistic_section).permit(
        measure_ids: [],
        comparisons_attributes: [:id, :is_anova,
          comparate_groups_attributes: [:id,
            comparates_attributes: [:id,
              comparable_element_attributes: [:id, :comparable_type, :comparable_id]]]])
#
#        measure_ids: [],
#        comparisons_attributes: [ :id, :_destroy, :result_statistic_section_id,
#          comparisons_measures_attributes: [ :id, :_destroy, :comparison_id, :measure_id ,
#          measurement_attributes: [ :id, :_destroy, :comparisons_measure_id, :value ] ],
#        comparate_groups_attributes: [ :id, :_destroy, :comparison_id,
#        comparates_attributes: [ :id, :_destroy, :comparate_group_id, :comparable_element_id,
#        comparable_element_attributes: [ :id, :_destroy, :comparable_type, :comparable_id, :_destroy ] ] ] ] )
    end

    def set_extractions
      @extractions = Extraction
        .includes(projects_users_role: { projects_user: { user: :profile } })
        .where(id: extraction_ids_params)
    end

    def extraction_ids_params
      params.require(:extraction_ids)
    end
end
