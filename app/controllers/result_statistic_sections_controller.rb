class ResultStatisticSectionsController < ApplicationController

  add_breadcrumb 'my projects', :projects_path

  before_action :skip_policy_scope

  before_action :set_result_statistic_section, only: [:edit, :update, :add_comparison, :remove_comparison, :consolidate]
  before_action :set_arms, only: [:edit, :update, :add_comparison, :remove_comparison, :consolidate]
  before_action :set_extractions, only: [:consolidate]
  before_action :set_result_statistic_section_associate_data, only: [:update, :add_comparison, :remove_comparison]
  #!!! Birol: don't think this is working...where is comparables set?
  #before_action :set_comparisons_measures, only: [:edit]

  # GET /result_statistic_sections/1/edit
  def edit
    add_breadcrumb 'edit project', edit_project_path(@result_statistic_section.extraction.project)
    add_breadcrumb 'extractions',  project_extractions_path(@result_statistic_section.extraction.project)
    add_breadcrumb 'work',         work_extraction_path(@result_statistic_section.extraction,
                                                          params: { eefpst1_id: @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1_id },
                                                          'panel-tab': @result_statistic_section.eefps_result.id)
    add_breadcrumb @result_statistic_section.result_statistic_section_type.name.downcase,
      :edit_result_statistic_section_path
  end

  # PATCH/PUT /result_statistic_sections/1
  # PATCH/PUT /result_statistic_sections/1.json
  def update
    respond_to do |format|
      if @result_statistic_section.update(result_statistic_section_params)
        format.html do |format|
          if params[:result_statistic_section].has_key? :extraction_ids
            redirect_to consolidate_result_statistic_section_path(@result_statistic_section,
              extraction_ids: params[:result_statistic_section][:extraction_ids]),
              notice: t('success')
          else
            redirect_to edit_result_statistic_section_path(@result_statistic_section),
                    notice: t('success')
          end
        end
        format.json { render :show, status: :ok, location: @result_statistic_section }
        format.js {}
      else
        format.html { render :edit }
        format.json { render json: @result_statistic_section.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_comparison
    respond_to do |format|
      if temp_result_statistic_section.update(result_statistic_section_params)
        format.html { redirect_to edit_result_statistic_section_path(@result_statistic_section),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @result_statistic_section }
        format.js { flash.now[:notice] = 'Comparison added' }
      else
        format.html do
          flash[:alert] = 'Invalid comparison'
          render :edit
        end
        format.json { render json: @result_statistic_section.errors, status: :unprocessable_entity }
        format.js { flash.now[:notice] = 'Invalid comparison' }
      end
    end
  end

  def remove_comparison
    respond_to do |format|
      if Comparison.find(params[:comparison_id]).destroy
        format.js { render :add_comparison }
      else
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
        if params[:extraction_ids].present?
          @extraction_ids = params[:extraction_ids]
        end
        @result_statistic_section = ResultStatisticSection.find(params[:rss_id])
        @result_statistic_section.result_statistic_sections_measures.build.build_measure
        @options = @result_statistic_section
          .result_statistic_section_type
          .result_statistic_section_types_measures
          .where(type1_type: @result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.type1_type)
          .map do |rsstm|
            [
              rsstm.measure.name,
              rsstm.measure.id,
              @result_statistic_section.measures.include?(rsstm.measure) ? { 'data-selected' => '' } : '',
              rsstm.provider_measure.present? ? { 'provider-measure-id' => rsstm.provider_measure.measure.id } : ''
            ]
        end

        @result_statistic_section.other_related_measures.each do |measure|
          next if @options.any? { |_, measure_id, _| measure_id == measure.id }
          @options << [
            measure.name,
            measure.id,
            @result_statistic_section.measures.include?(measure) ? { 'data-selected' => '' } : '',
            ''
          ]
        end

        @options.uniq!

        # Create a dictionary that carries as keys the id of a provider measure and values an Array of options.
        @dict_of_dependencies = Hash.new { |hash, key| hash[key] = [] }
        @options.each do |opt|
          if opt[3].present?
            @dict_of_dependencies[opt[3].values] << opt
          end
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
        :comparison_type,
        measures_attributes: [:id, :name, :_destroy],
        measure_ids: [],
        result_statistic_sections_measures_attributes: [measure_attributes: [:id, :name]],
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

    def set_result_statistic_section_associate_data
      @eefpst1 = @result_statistic_section.
        population.
        extractions_extraction_forms_projects_sections_type1
      @extraction = @result_statistic_section.extraction
      @project = @result_statistic_section.project
      @extraction_forms_projects = @project.extraction_forms_projects
      @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1.
        by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Outcomes',
          @extraction.id,
          @extraction_forms_projects.first.id
        )
    end

    def temp_result_statistic_section
      # This is required because in the NET Change section we have both types of comparisons; BAC and WAC. So in order to create the comparison
      # in the correct section we use a hidden form input :comparison_type.
      if params[:result_statistic_section]['comparison_type'] == 'bac'
        @result_statistic_section.population.result_statistic_sections.find_by(result_statistic_section_type_id: 2)
      elsif params[:result_statistic_section]['comparison_type'] == 'wac'
        @result_statistic_section.population.result_statistic_sections.find_by(result_statistic_section_type_id: 3)
      elsif params[:result_statistic_section]['comparison_type'] == 'diagnostic_test'
        @result_statistic_section.population.result_statistic_sections.find_by(result_statistic_section_type_id: 5)
      end
    end
end
