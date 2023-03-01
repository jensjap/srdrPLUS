class SdMetaDataController < ApplicationController
  # Birol: although bucket swapping works, it is unnecessary, since at the moment converted pdfs has to be stored on disk
  # around_action :wrap_in_bucket_swap, only: [:create, :destroy, :show, :edit]
  around_action :wrap_in_transaction

  def show
    @systematic_review_report = true
    @panel_number = params[:panel_number].try(:to_i) || 0
    @sd_meta_datum = SdMetaDatum.find(params[:id])
    @project = @sd_meta_datum.try(:project)
    authorize(@sd_meta_datum)
    @nav_buttons.push('sr_360', 'my_projects')
    @report = @sd_meta_datum.report
  end

  def mapping_update
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    project_id = sd_meta_datum.project&.id
    if project_id.nil?
      head :bad_request
      return
    end
    authorize(sd_meta_datum)
    key_questions = mapping_params[:key_questions].to_h || {}
    key_questions = key_questions.map { |key, value| { key => value.uniq } }
    SdKeyQuestionsProject
      .where(sd_key_question_id: SdMetaDatum
      .find(params[:sd_meta_datum_id])
      .sd_key_questions)
      .destroy_all
    key_questions.each do |mapping_hash|
      mapping_hash.each do |kq_id, key_q_ids|
        key_q_ids.each do |sd_kq_id|
          key_questions_project_id = KeyQuestionsProject.find_by(key_question_id: kq_id,\
                                                                 project_id:)&.id
          SdKeyQuestionsProject.create(key_questions_project_id:,\
                                       sd_key_question_id: sd_kq_id)
        end
      end
    end
    head :no_content
  end

  def preview
    respond_to do |format|
      format.js do
        @panel_number = params[:panel_number].try(:to_i) || 0
        @sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
        @project = @sd_meta_datum.try(:project)
        authorize(@sd_meta_datum)
      end
    end
  end

  def section_update
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_meta_datum.update(section_params)
    render json: { status: section_params.values.first }, status: 200
  end

  def destroy
    sd_meta_datum = SdMetaDatum.find(params[:id])
    project = sd_meta_datum.project
    authorize(sd_meta_datum)
    sd_key_questions_ids = sd_meta_datum.sd_key_questions.map(&:id)

    SdKeyQuestionsProject.where(sd_key_question_id: sd_key_questions_ids).destroy_all
    SdSummaryOfEvidence.where(id: sd_meta_datum.sd_summary_of_evidences.map(&:id)).destroy_all

    sd_meta_datum.destroy
    if sd_meta_datum.destroyed?
      flash[:notice] = "Succesfully deleted Sd Meta Datum ID: #{sd_meta_datum.id}"
    else
      flash[:alert] = "Error deleting Sd Meta Datum ID: #{sd_meta_datum.id}"
    end

    redirect_to project_sd_meta_data_path(project)
  end

  def create
    @sd_meta_datum = SdMetaDatum.new(new_sd_meta_datum_params)
    authorize(@sd_meta_datum)
    @sd_meta_datum.save!
    #    # For Demo Only START
    #    Parser.parse(@sd_meta_datum) if @sd_meta_datum.report.try(:accession_id) == "NBK534625"
    #    # For Demo Only END
    @sd_meta_datum.create_fuzzy_matches
    flash[:notice] =
      "Succesfully created Sd Meta Datum ID: #{@sd_meta_datum.id} for Project ID: #{@sd_meta_datum.project_id}"
    redirect_to edit_sd_meta_datum_path(@sd_meta_datum.id)
  end

  def edit
    respond_to do |format|
      format.json do
        @sd_meta_datum = SdMetaDatum.find(params[:id])
        @project = @sd_meta_datum.project
      end
      format.html do
        @systematic_review_report = true
        @panel_number = params[:panel_number].try(:to_i) || 0
        @sd_meta_datum = SdMetaDatum.includes(
          # :key_questions,
          # :sd_key_questions_projects,
          # :project_key_questions,
          # :sd_key_questions_sd_picods,
          # :sd_journal_article_urls,
          # :sd_other_items,
          # :sd_search_strategies,
          # :sd_search_databases,
          # :sd_summary_of_evidences,
          # :sd_grey_literature_searches,
          # :sd_prisma_flows,
          # :sd_picods,
          # :sd_analytic_frameworks,
          # :funding_sources_sd_meta_data,
          # :funding_sources,
          # :sd_meta_data_queries,
          # :publishing,
          {
            sd_result_items: { sd_key_question: :key_question },
            sd_narrative_results: :sd_outcomes,
            sd_evidence_tables: :sd_outcomes,
            sd_pairwise_meta_analytic_results: %i[sd_outcomes sd_meta_data_figures],
            sd_network_meta_analysis_results: :sd_outcomes,
            sd_meta_regression_analysis_results: :sd_outcomes
          }
        ).find(params[:id])
        # @sd_meta_datum.sd_journal_article_urls.build
        # @sd_meta_datum.sd_other_items.build
        # @sd_meta_datum.sd_grey_literature_searches.build
        # @sd_meta_datum.sd_prisma_flows.build
        # @sd_meta_datum.sd_meta_regression_analysis_results.build
        # @sd_meta_datum.sd_evidence_tables.build
        @project = @sd_meta_datum.project
        authorize(@sd_meta_datum)
        @nav_buttons.push('sr_360', 'my_projects')
        @report = @sd_meta_datum.report
        @url = sd_meta_datum_path(@sd_meta_datum)

        if @report.present?
          # PDF preview.
          accession_id = @report.accession_id
          @report_html_path = "https://srdrplus-report-htmls.s3.amazonaws.com/reports/#{accession_id}/TOC.html"
        elsif @sd_meta_datum.report_file.present?
          # PDF preview for reports selected from dropdown.
          # accession_id = "sd_meta_datum_" + @sd_meta_datum.id.to_s
          # @report_html_path = "/reports/#{ accession_id }/TOC.html"
          # unless File.exists?("#{ Rails.root }/public/" + @report_html_path)
          #   ConvertPdf2HtmlJob.set(wait: 1.minute).perform_later(accession_id, @sd_meta_datum.id)
          # end
          @report_html_path = rails_blob_path(@sd_meta_datum.report_file)
        end

        return render :new_template if params[:new_template]
      end
    end
  end

  def update
    @sd_meta_datum = SdMetaDatum.find(params[:id])
    @project = Project.find(@sd_meta_datum.project_id)
    authorize(@sd_meta_datum)
    @url = sd_meta_datum_path(@sd_meta_datum)
    update = @sd_meta_datum.update(sd_meta_datum_params)
    respond_to do |format|
      format.js do
        @errors = @sd_meta_datum.errors.full_messages unless update
        set_partial_name_and_container_class params[:sd_meta_datum][:item_id].to_i
        set_report_title_update_flag(params[:sd_meta_datum][:report_title].present?)
      end
      format.html do
        redirect_to edit_sd_meta_datum_path(@sd_meta_datum.id)
      end
    end
  end

  def index
    # @projects = policy_scope(Project)
    @project = Project.find(params[:project_id])
    authorize(@project, policy_class: SdMetaDatumPolicy)
    @nav_buttons.push('sr_360', 'my_projects')
    @reports = Report.all
    @sd_meta_data = policy_scope(SdMetaDatum).where(project: @project)
  end

  private

  def set_bucket
    service = ActiveStorage::Blob.service
    return unless service.present?
    return unless service.class.to_s == 'ActiveStorage::Service::S3Service'

    perm_bucket = nil
    service.client.buckets.each do |bucket|
      perm_bucket = bucket if bucket.name == 'srdrplus-uploads'
    end
    service.set_bucket(perm_bucket)
    service.set_public(true)
  end

  def revert_bucket
    service = ActiveStorage::Blob.service
    return unless service.present?
    return unless service.class.to_s == 'ActiveStorage::Service::S3Service'

    temp_bucket = nil
    service.client.buckets.each do |bucket|
      temp_bucket = bucket if bucket.name == 'srdrplus-temp'
    end
    service.set_bucket(temp_bucket)
    service.set_public(false)
  end

  def set_partial_name_and_container_class(item_id)
    div_partial_dict = {
      #      63 => { :class => '.meta-regression-analysis-result-list',\
      #              :partial => 'sd_meta_data/form/nested_associations/meta_regression_analysis_result_list' },\
      #      61 => { :class => '.network-meta-analysis-result-list',\
      #              :partial => 'sd_meta_data/form/nested_associations/network_meta_analysis_result_list' },\
      #      59 => { :class => '.pairwise-meta-analytic-result-list',\
      #              :partial => 'sd_meta_data/form/nested_associations/pairwise_meta_analytic_result_list' },\
      #      58 => { :class => '.evidence-table-list',\
      #              :partial => 'sd_meta_data/form/nested_associations/evidence_table_list' },\
      #      56 => { :class => '.comparison-outcome-by-intervention-subgroup-list',\
      #              :partial => 'sd_meta_data/form/nested_associations/comparison_outcome_by_intervention_subgroup_list' },\
      #      54 => { :class => '.comparison-outcome-by-population-subgroup-list',\
      #              :partial => 'sd_meta_data/form/nested_associations/comparison_outcome_by_population_subgroup_list' },\
      50 => { class: '.result-list',\
              partial: 'sd_meta_data/form/nested_associations/result_list' },\
      49 => { class: '.prisma-list',\
              partial: 'sd_meta_data/form/nested_associations/prisma_list' },\
      48 => { class: '.grey-literature-list',\
              partial: 'sd_meta_data/form/nested_associations/grey_literature_list' },\
      44 => { class: '.search-strategy-list',\
              partial: 'sd_meta_data/form/nested_associations/search_strategy_list' },\
      38 => { class: '.picod-list',\
              partial: 'sd_meta_data/form/nested_associations/picod_list' },\
      36 => { class: '.key-question-list',\
              partial: 'sd_meta_data/form/nested_associations/key_question_list' },\
      35 => { class: '.analytic-framework-list',\
              partial: 'sd_meta_data/form/nested_associations/analytic_framework_list' },\
      26 => { class: '.journal-article-url-list',\
              partial: 'sd_meta_data/form/nested_associations/journal_article_url_list' },\
      27 => { class: '.other-item-list',\
              partial: 'sd_meta_data/form/nested_associations/other_item_list' },\
      100 => { class: '.result-item-list',\
               partial: 'sd_meta_data/form/nested_associations/result_item_list' }\
    }.freeze
    if div_partial_dict.key? item_id
      @container = div_partial_dict[item_id][:class]
      @partial_name = div_partial_dict[item_id][:partial]
    end
  end

  def set_report_title_update_flag(bool)
    @report_title_updated = true if bool
  end

  def wrap_in_bucket_swap
    set_bucket
    yield
  ensure
    revert_bucket
  end

  def wrap_in_transaction(&block)
    ActiveRecord::Base.transaction(&block)
  end

  def mapping_params
    params
      .require(:sd_meta_datum)
      .permit(:_, key_questions: {})
  end

  def section_params
    params
      .require(:sd_meta_datum)
      .permit(
        :section_flag_0,
        :section_flag_1,
        :section_flag_2,
        :section_flag_3,
        :section_flag_4,
        :section_flag_5,
        :section_flag_6,
        :section_flag_7,
        :section_flag_8
      )
  end

  def new_sd_meta_datum_params
    params
      .require(:sd_meta_datum)
      .permit(
        :project_id,
        :report_accession_id,
        :report_file
      )
  end

  def sd_meta_datum_params
    params
      .require(:sd_meta_datum)
      .permit(
        :project_id,
        :report_title,
        { funding_source_ids: [] },
        :date_of_last_search,
        :date_of_publication_to_srdr,
        :date_of_publication_full_report,
        :state,
        :stakeholders_key_informants,
        :stakeholders_technical_experts,
        :stakeholders_peer_reviewers,
        :stakeholders_others,
        :organization,
        :authors,
        :authors_conflict_of_interest_of_full_report,
        :prospero_link,
        :protocol_link,
        :full_report_link,
        :structured_abstract_link,
        :key_messages_link,
        :abstract_summary_link,
        :evidence_summary_link,
        { sd_journal_article_urls_attributes: %i[id name _destroy id] },
        { sd_other_items_attributes: %i[id name url _destroy id] },
        :disposition_of_comments_link,
        :srdr_data_link,
        :most_previous_version_srdr_link,
        :most_previous_version_full_report_link,
        :overall_purpose_of_review,
        :review_type_id,
        { sd_analytic_frameworks_attributes: [:id, :name, :_destroy, :id,
                                              { sd_meta_data_figures_attributes: [:id, :_destroy, :p_type, :alt_text, { pictures: [] }] }] },
        { sd_key_questions_attributes: [:includes_meta_analysis, :key_question_name, { key_question_type_ids: [] },
                                        :_destroy, :id, { sd_key_questions_key_question_type_ids: [] }] },
        { sd_key_question_ids: [] },
        { sd_picods_attributes: [:data_analysis_level_id, :name, :population, :interventions, :comparators,
                                 :outcomes, :study_designs, :timing, :settings, :other_elements, :_destroy, :id, { sd_key_question_ids: [], sd_picods_type_ids: [] }] },
        { sd_search_strategies_attributes: %i[sd_search_database_id date_of_search search_limits
                                              search_terms _destroy id] },
        { sd_grey_literature_searches_attributes: %i[name _destroy id] },
        { sd_prisma_flows_attributes: [:name, :_destroy, :id,
                                       { sd_meta_data_figures_attributes: [:id, :_destroy, :p_type, :alt_text, { pictures: [] }] }] },
        { sd_result_items_attributes: [:sd_key_question_id, :_destroy, :id,
                                       { sd_narrative_results_attributes: [:narrative_results, :narrative_results_by_population, :narrative_results_by_intervention, :_destroy, :id, { sd_outcome_names: [] }] },
                                       { sd_evidence_tables_attributes: [:name, :_destroy, :id, { sd_meta_data_figures_attributes: [:id, :_destroy, :p_type, :alt_text, { pictures: [] }] }, { sd_outcome_names: [] }] },
                                       { sd_network_meta_analysis_results_attributes: [:name, :_destroy, :id, { sd_meta_data_figures_attributes: [:id, :_destroy, :p_type, :alt_text, { pictures: [] }] }, { sd_outcome_names: [] }] },
                                       { sd_pairwise_meta_analytic_results_attributes: [:name, :_destroy, :id, { sd_meta_data_figures_attributes: [:id, :_destroy, :p_type, :alt_text, :outcome_type, :intervention_name, :comparator_name, :effect_size_measure_name, :overall_effect_size, :overall_95_ci_low, :overall_95_ci_high, :overall_i_squared, :other_heterogeneity_statistics, { pictures: [] }] }, { sd_outcome_names: [] }] },
                                       { sd_meta_regression_analysis_results_attributes: [:name, :_destroy, :id, { sd_meta_data_figures_attributes: [:id, :_destroy, :p_type, :alt_text, { pictures: [] }] }, { sd_outcome_names: [] }] }] },
        { sd_summary_of_evidences_attributes: [:soe_type, :sd_key_question_id, :name, :_destroy, :id,
                                               { sd_meta_data_figures_attributes: [:id, :_destroy, :p_type, :alt_text, { pictures: [] }] }] }

      )
  end
end
