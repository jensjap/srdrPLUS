class ProjectsController < ApplicationController
  add_breadcrumb "my projects", :projects_path

  before_action :set_project, only: [
                                :show, :edit, :update, :destroy, :export, :export_to_gdrive, :import_csv,
                                :import_pubmed, :import_endnote, :import_ris, :next_assignment,
                                :confirm_deletion, :dedupe_citations, :create_citation_screening_extraction_form, :create_full_text_screening_extraction_form,
                              ]

  before_action :skip_authorization, only: [:index, :edit, :show, :filter, :export, :export_to_gdrive, :new, :create]
  before_action :skip_policy_scope, except: [
                                      :index, :show, :edit, :update, :destroy, :filter, :export, :export_to_gdrive, :import_csv,
                                      :import_pubmed, :import_endnote, :import_ris, :next_assignment,
                                    ]

  # GET /projects
  # GET /projects.json
  def index
    setup_instance_variables
  end

  # GET /projects/filter
  # GET /projects/filter.json
  def filter
    setup_instance_variables
    render "index"
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
    # authorize(@project)
    add_breadcrumb "edit project", :edit_project_path
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    respond_to do |format|
      if save_without_sections_if_imported_files_params_exist @project
        format.html {
          redirect_to edit_project_path(@project),
                      notice: t("success") + " #{make_undo_link}"
        }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    authorize(@project)

    respond_to do |format|
      if @project.update(project_params)
        format.html {
          redirect_back(fallback_location: edit_project_path(@project, anchor: "panel-project-information"),
                        notice: t("success") + " #{make_undo_link}")
        }
        format.json { render :show, status: :ok, location: @project }
        format.js { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
        format.js { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /projects/1/confirm_deletion.js
  def confirm_deletion
    respond_to do |format|
      format.js
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    authorize(@project)

    @project.destroy
    respond_to do |format|
      format.html {
        redirect_to projects_url,
                    notice: t("removed") + " #{make_undo_link}"
      }
      format.json { head :no_content }
    end
  end

  def undo
    @project_version = PaperTrail::Version.find_by_id(params[:id])
    authorize(@project_version.item)

    begin
      if @project_version.reify
        @project_version.reify.save
      else
        # For undoing the create action
        @project_version.item.destroy
      end
      flash[:success] = "Undid that! #{make_redo_link}"
    rescue
      flash[:alert] = "Failed undoing the action..."
    ensure
      if Project.where(id: @project_version.item.id).present?
        redirect_to edit_project_path(@project_version.item, anchor: "panel-information")
      else
        redirect_to projects_path
      end
    end
  end

  def export
    authorize(@project)
    SimpleExportJob.perform_now(current_user.id, @project.id, export_type_name)
    flash[:success] = "Export request submitted for project '#{@project.name}'. You will be notified by email of its completion."

    # redirect_to edit_project_path(@project)
    redirect_to request.referer
  end

  def export_to_gdrive
    authorize(@project)
    GsheetsExportJob.perform_later(current_user.id, @project.id, gdrive_params)
    flash[:success] = "Export request submitted for project '#{@project.name}'. You will be notified by email of its completion."

    redirect_to edit_project_path(@project)
  end

  def import_ris
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    RisImportJob.perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] = "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."
    #@project.import_citations_from_ris( citation_import_params[:citation_file] )

    redirect_to project_citations_path(@project)
  end

  def import_csv
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    CsvImportJob.perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] = "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."
    #@project.import_citations_from_csv( citation_import_params[:citation_file] )

    redirect_to project_citations_path(@project)
  end

  def import_pubmed
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    PubmedImportJob.perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] = "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."
    #@project.import_citations_from_pubmed( citation_import_params[:citation_file] )

    redirect_to project_citations_path(@project)
  end

  def import_endnote
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    EnlImportJob.perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] = "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."
    #@project.import_citations_from_enl( citation_import_params[:citation_file] )

    redirect_to project_citations_path(@project)
  end

  def next_assignment
    authorize(@project)
    projects_user = ProjectsUser.where(project: @project, user: current_user).first
    next_assignment = projects_user.assignments.first

    redirect_to controller: :assignments, action: :screen, id: next_assignment.id
  end

  def dedupe_citations
    authorize(@project)
    DedupeCitationsJob.perform_later(@project.id)
    #@project.dedupe_citations
    flash[:success] = "Request to deduplicate citations has been received. Please come back later."

    redirect_to project_citations_path(@project)
  end

  def create_citation_screening_extraction_form
    authorize(@project)
    @project.extraction_forms_projects.find_or_create_by(
      extraction_forms_project_type: ExtractionFormsProjectType.find_or_create_by(name: "Citation Screening Extraction Form"),
      extraction_form: ExtractionForm.find_or_create_by(name: "ef2"),
    )
    flash[:success] = "Success."

    redirect_to edit_project_path(@project, anchor: "panel-citation-screening-extraction-form"), notice: t("success")
  end

  def create_full_text_screening_extraction_form
    authorize(@project)
    @project.extraction_forms_projects.find_or_create_by(
      extraction_forms_project_type: ExtractionFormsProjectType.find_or_create_by(name: "Full Text Screening Extraction Form"),
      extraction_form: ExtractionForm.find_or_create_by(name: "ef3"),
    )
    flash[:success] = "Success."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.
      includes(publishing: :approval).
      find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    if action_name != 'create'
      params.require(:project).permit(policy(@project).permitted_attributes)
    else
      params.require(:project).permit(*ProjectPolicy::FULL_PARAMS)
    end
  end

  def gdrive_params
    #params.permit( :kqp_ids => [], :payload => [ :column_name, :type, { :export_ids => [] } ] )
    params.permit(:kqp_ids => [],
                  :columns => [:name, :type,
                               { :export_items => [:export_id, :type, :extraction_forms_projects_section_id] }])
  end

  def save_without_sections_if_imported_files_params_exist(project)
    @project = project
    if project_params[:projects_users_attributes].present?
      project.create_empty = true
      if not project.save
        return false
      end
      if project.imported_files.present?
        flash[:success] = "Import request submitted for project '#{project.name}'. You will be notified by email of its completion."
      end
      return true
    end
    project.save
  end

  #def import_params
  #  params.require(:project)
  #      .permit(
  #end

  # def distiller_params
  #   # what kind of files do we want to import?
  #   params.require(:project).permit(:citation_file, :design_file, :arms_file, :outcomes_file, :bc_file, :rob_file)
  # end

  # def json_params
  #   params.require(:project).permit(:json_file)
  # end

  def citation_import_params
    # what kind of files do we want to import?
    params.require(:project).permit(:citation_files => [])
  end

  def export_type_name
    params.require(:export_type_name)
  end

  def make_undo_link
    #!!! This is wrong. Just because there's an older version doesn't mean we should be able to revert to it.
    #    This could have been called when Assignment was created.
    return ""

    if @project.versions.present?
      view_context.link_to "<u><strong>Undo that please!</strong></u>".html_safe, undo_project_path(@project.versions.last), method: :post
    end
  end

  def make_redo_link
    params[:redo] == "true" ? link = "<u><strong>Undo that please!</strong></u>".html_safe : link = "<u><strong>Redo that please!</strong></u>".html_safe
    view_context.link_to link, undo_project_path(@project_version.next, redo: !params[:redo]), method: :post
  end

  # def import_project_from_json(project, f)
  #   JsonImportJob.perform_later(current_user.id, project.id, f[:json_file].path)
  #   flash[:success] = "Import request submitted for project '#{ project.name }'. You will be notified by email of its completion."
  # end

  # def import_project_from_distiller(project)
  #   DistillerImportJob.perform_later(current_user.id, project.id)
  #   flash[:success] = "Import request submitted for project '#{ project.name }'. You will be notified by email of its completion."
  # end


  def setup_instance_variables
    @query = params.dig(:project, :q)
    @order = params[:o] || "updated-at"
    @project_status = params.dig(:project, :project_status) || params[:project_status]
    @params = { project: { q: @query }, project_status: @project_status }

    if @project_status.blank?
      @projects = policy_scope(Project).
        draft.
        includes(publishing: [{ user: :profile }, approval: [{ user: :profile }]]).
        by_name_description_and_query(@query).
        page(params[:page])

      @projects = @projects.order(updated_at: :desc) if params[:o].nil? || params[:o] == 'updated-at'
      @projects = @projects.order(created_at: :desc) if params[:o] == 'created-at'

      project_ids = @projects.pluck(:id)
      @projects_key_questions_project_counts = KeyQuestionsProject.
        where(project_id: project_ids).
        group(:project_id).
        count

      @projects_citations_project_counts = CitationsProject.
        where(project_id: project_ids).
        group(:project_id).
        count

      @projects_projects_user_counts = ProjectsUser.
        where(project_id: project_ids).
        group(:project_id).
        count

      @projects_extraction_counts = Extraction.
        where(project_id: project_ids).
        group(:project_id).
        count

      @projects_extraction_forms_project_ids = ExtractionFormsProject.
        where(project_id: project_ids).
        group_by(&:project_id)

      @sd_meta_data_counts = SdMetaDatum.
        where(project_id: project_ids).
        group(:project_id).
        count

      @projects_lead_or_with_key_questions = ProjectsUsersRole.
        where(projects_user: ProjectsUser.
          where(
            project_id: project_ids,
            user_id: current_user
          ),
          role: Role.where(name: 'Leader')
        ).includes(projects_user: { project: [ :key_questions_projects ] }).
        map { |pur| [pur.project.id, pur.project.key_questions_projects.present?] }.
        to_h

      @projects_lead_or_with_key_questions.default = false
    elsif @project_status == 'pending'
      @unapproved_publishings = Publishing.
        includes([:publishable]).
        joins('left join projects ON publishings.publishable_id = projects.id').
        joins('left join sd_meta_data ON sd_meta_data.id = publishings.publishable_id').
        where("projects.name LIKE ? OR sd_meta_data.report_title LIKE ?", "%#{@query}%", "%#{@query}%").
        unapproved.
        page(params[:page])
      @unapproved_publishings = @unapproved_publishings.order(updated_at: :desc) if params[:o].nil? || params[:o] == 'updated-at'
      @unapproved_publishings = @unapproved_publishings.order(created_at: :desc) if params[:o] == 'created-at'
      @unapproved_publishings = @unapproved_publishings.where(user: current_user) unless current_user.admin?
    elsif @project_status == 'published'
      @approved_publishings = Publishing.
        includes([:publishable]).
        preload(:approval).
        joins('left join projects ON publishings.publishable_id = projects.id').
        joins('left join sd_meta_data ON sd_meta_data.id = publishings.publishable_id').
        where("projects.name LIKE ? OR sd_meta_data.report_title LIKE ?", "%#{@query}%", "%#{@query}%").
        approved.
        page(params[:page])
      @approved_publishings = @approved_publishings.order(updated_at: :desc) if params[:o].nil? || params[:o] == 'updated-at'
      @approved_publishings = @approved_publishings.order(created_at: :desc) if params[:o] == 'created-at'
      @approved_publishings = @approved_publishings.where(user: current_user) unless current_user.admin?
    end
  end
end
