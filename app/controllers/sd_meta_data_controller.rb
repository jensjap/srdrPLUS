class SdMetaDataController < ApplicationController
  add_breadcrumb 'my project-report links', :sd_meta_data_path

  around_action :wrap_in_transaction

  def show
    @systematic_review_report = true
    @panel_number = params[:panel_number].try(:to_i) || 0
    @sd_meta_datum = SdMetaDatum.find(params[:id])
    @project = @sd_meta_datum.try(:project)
    @report = @sd_meta_datum.report
    add_breadcrumb 'view project-report link',  sd_meta_datum_url(@sd_meta_datum)
  end

  def mapping_update
    key_questions = mapping_params[:key_questions].to_h || {}
    key_questions = key_questions.map { |key, value| { key => value.uniq } }
    SdKeyQuestionsProject.
      where(sd_key_question_id: SdMetaDatum.
      find(params[:sd_meta_datum_id]).
      sd_key_questions).
      destroy_all
    key_questions.each do |mapping_hash|
      mapping_hash.each do |kq_project_id, key_q_ids|
        key_q_ids.each do |sd_kq_id|
          SdKeyQuestionsProject.create(key_questions_project_id: kq_project_id, sd_key_question_id: sd_kq_id)
        end
      end
    end
    head :no_content
  end

  def section_update
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    sd_meta_datum.update(section_params)
    render json: { status: section_params.values.first }, status: 200
  end

  def destroy
    sd_meta_datum =  SdMetaDatum.find(params[:id])
    sd_key_questions_ids = sd_meta_datum.sd_key_questions.map(&:id)

    SdKeyQuestionsProject.where(sd_key_question_id: sd_key_questions_ids).destroy_all
    SdSummaryOfEvidence.where(id: sd_meta_datum.sd_summary_of_evidences.map(&:id)).destroy_all

    sd_meta_datum.destroy
    if sd_meta_datum.destroyed?
      flash[:notice] = "Succesfully deleted Sd Meta Datum ID: #{sd_meta_datum.id}"
    else
      flash[:alert] = "Error deleting Sd Meta Datum ID: #{sd_meta_datum.id}"
    end
    redirect_to sd_meta_data_path
  end

  def create
    @sd_meta_datum = SdMetaDatum.create(new_sd_meta_datum_params)
    # For Demo Only START
    Parser.parse(@sd_meta_datum) if @sd_meta_datum.report.try(:accession_id) == "NBK534625"
    # For Demo Only END
    @sd_meta_datum.create_fuzzy_matches
    flash[:notice] = "Succesfully created Sd Meta Datum ID: #{@sd_meta_datum.id} for Project ID: #{@sd_meta_datum.project_id}"
    redirect_to edit_sd_meta_datum_path(@sd_meta_datum.id)
  end

  def edit
    @systematic_review_report = true
    @panel_number = params[:panel_number].try(:to_i) || 0
    @sd_meta_datum = SdMetaDatum.find(params[:id])
    @sd_meta_datum.sd_journal_article_urls.build
    @sd_meta_datum.sd_other_items.build
    @sd_meta_datum.sd_grey_literature_searches.build
    @sd_meta_datum.sd_prisma_flows.build
    @sd_meta_datum.sd_meta_regression_analysis_results.build
    @project = @sd_meta_datum.try(:project)
    @report = @sd_meta_datum.report
    @url = sd_meta_datum_path(@sd_meta_datum)
 
    add_breadcrumb 'edit project-report link', edit_sd_meta_datum_url(@sd_meta_datum)
end

  def update
    @sd_meta_datum = SdMetaDatum.find(params[:id])
    @project = Project.find(@sd_meta_datum.project_id)
    @url = sd_meta_datum_path(@sd_meta_datum)
    sd_meta_datum = SdMetaDatum.find(params[:id])
    update = sd_meta_datum.update(sd_meta_datum_params)
    respond_to do |format|
      format.js do
        unless update
          @errors = sd_meta_datum.errors.full_messages
        end
      end
      format.html do |format|
        redirect_to edit_sd_meta_datum_path(sd_meta_datum.id)
      end
    end
  end

  def index
    @projects = Project.all
    @reports = Report.all
    @sd_meta_data = policy_scope(SdMetaDatum)
  end

  private

    def wrap_in_transaction
      ActiveRecord::Base.transaction do
        begin
          yield
        ensure
        end
      end
    end

    def mapping_params
      params.
        require(:sd_meta_datum).
          permit(:_, key_questions: { })
    end

    def section_params
      params.
        require(:sd_meta_datum).
          permit(
            :section_flag_0,
            :section_flag_1,
            :section_flag_2,
            :section_flag_3,
            :section_flag_4,
            :section_flag_5,
            :section_flag_6,
            :section_flag_7,
            )
    end

    def new_sd_meta_datum_params
      params.
        require(:sd_meta_datum).
        permit(
          :project_id,
          :report_accession_id
        )
    end

    def sd_meta_datum_params
      params.
        require(:sd_meta_datum).
        permit(
          :project_id,
          :report_title,
          { funding_source_ids: [] },
          :date_of_last_search,
          :date_of_publication_to_srdr,
          :date_of_publication_full_report,
          :state,
          :stakeholder_involvement_extent,
          :authors,
          :authors_conflict_of_interest_of_full_report,
          :stakeholders_conflict_of_interest,
          :prototcol_link,
          :full_report_link,
          :structured_abstract_link,
          :key_messages_link,
          :abstract_summary_link,
          :evidence_summary_link,
          :evs_introduction_link,
          :evs_methods_link,
          :evs_results_link,
          :evs_discussion_link,
          :evs_conclusions_link,
          :evs_tables_figures_link,
          { sd_journal_article_urls_attributes: [:id, :name, :_destroy, :id] },
          { sd_other_items_attributes: [:id, :name, :url, :_destroy, :id] },
          :disposition_of_comments_link,
          :srdr_data_link,
          :most_previous_version_srdr_link,
          :most_previous_version_full_report_link,
          :overall_purpose_of_review,
          :type_of_review,
          :level_of_analysis,
          { sd_analytic_frameworks_attributes: [:id, :name, :_destroy, :id, pictures: []] },
          { sd_key_questions_attributes: [:key_question_id, { key_question_type_ids: [] }, :name, :_destroy, :id, { sd_key_questions_key_question_type_ids: [] }] },
          { sd_key_question_ids: [] },
          { sd_picods_attributes: [:name, :population, :interventions, :comparators, :outcomes, :study_designs, :settings, :_destroy, :id, sd_key_question_ids: [], sd_picods_type_ids: []] },
          { sd_search_strategies_attributes: [:sd_search_database_id, :date_of_search, :search_limits, :search_terms, :_destroy, :id] },
          { sd_grey_literature_searches_attributes: [:name, :_destroy, :id] },
          { comparison_outcome_intervention_subgroups_attributes: [:sd_key_question_id, :narrative_results, :name, :_destroy, :id] },
          { comparison_outcome_population_subgroups_attributes: [:sd_key_question_id, :narrative_results, :name, :_destroy, :id] },
          { sd_evidence_tables_attributes: [:name, :_destroy, :id] },
          { sd_prisma_flows_attributes: [:name, :_destroy, :id, pictures: []] },
          { network_meta_analysis_results_attributes: [:name, :p_type, :_destroy, :id, pictures: []] },
          { pairwise_meta_analytic_results_attributes: [:name, :p_type, :_destroy, :id, pictures: []] },
          { sd_forest_plots_attributes: [:name, :_destroy, :id, pictures: []] },
          { sd_meta_regression_analysis_results_attributes: [:name, :_destroy, :id, :picture] },
          { sd_summary_of_evidences_attributes: [:sd_key_question_id, :soe_type, :name, :_destroy, :id, pictures: []] }
        )
    end
end
