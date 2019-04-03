class ProjectsController < ApplicationController
  add_breadcrumb 'my projects', :projects_path

  before_action :set_project, only: [
    :show, :edit, :update, :destroy, :export, :import_csv,
    :import_pubmed, :import_endnote, :import_ris, :next_assignment,
    :confirm_deletion
  ]

  before_action :skip_authorization, only: [:index, :show, :filter, :export, :new, :create]
  before_action :skip_policy_scope, except: [
    :index, :show, :edit, :update, :destroy, :filter, :export, :import_csv,
    :import_pubmed, :import_endnote, :import_ris, :next_assignment
  ]

  SORT = {
    'updated-at': { updated_at: :desc },
    'created-at': { created_at: :desc },
  }.stringify_keys

  # GET /projects
  # GET /projects.json
  def index
    msg = Message.get_totd.check_message
    flash.now[:info] = msg if msg
    @query = params[:q]
    @order = params[:o] || 'updated-at'

    @projects = policy_scope(Project).includes(:extraction_forms)
      .includes(:key_questions)
      .includes(publishings: [{ user: :profile }, approval: [{ user: :profile }]])
      .by_query(@query).order(SORT[@order]).page(params[:page])
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
    authorize(@project)
    @citation_dict = @project.citations.eager_load(:authors, :journal, :keywords).map{ |c| [c.id, c] }.to_h
    @citations_projects = @project.citations_projects

    add_breadcrumb 'edit project', :edit_project_path
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to edit_project_path(@project),
                      notice: t('success') + " #{ make_undo_link }" }
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
        format.html { redirect_to edit_project_path(@project, anchor: 'panel-information'),
                      notice: t('success') + " #{ make_undo_link }" }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
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
      format.html { redirect_to projects_url,
                    notice: t('removed') + " #{ make_undo_link }" }
      format.json { head :no_content }
    end
  end

  # GET /projects/filter
  # GET /projects/filter.json
  def filter
    @query = params[:q]  # Need @query for index partial.
    @order = params[:o]

    @projects = policy_scope(Project).includes(publishings: [{ user: :profile }, approval: [{ user: :profile }]])
      .includes(:key_questions)
      .by_name_description_and_query(@query).order(SORT[@order]).page(params[:page])
    render 'index'
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
      flash[:success] = "Undid that! #{ make_redo_link }"
    rescue
      flash[:alert] = "Failed undoing the action..."
    ensure
      if Project.where(id: @project_version.item.id).present?
        redirect_to edit_project_path(@project_version.item, anchor: 'panel-information')
      else
        redirect_to projects_path
      end
    end
  end

  def export
    authorize(@project)
    SimpleExportJob.perform_later(current_user.id, @project.id)
    flash[:success] = "Export request submitted for project '#{ @project.name }'. You will be notified by email of its completion."

    redirect_to edit_project_path(@project)
  end

  def import_csv
    authorize(@project)
    if params[:project].present? and params[:project][:citation_file].present?
      @project.import_citations_from_csv( params[:project][:citation_file] )
    end
    redirect_to edit_project_path(@project, anchor: 'panel-citations')
  end

  def import_pubmed
    authorize(@project)
    if params[:project].present? and params[:project][:citation_file].present?
      @project.import_citations_from_pubmed( params[:project][:citation_file] )
    end
    redirect_to edit_project_path(@project, anchor: 'panel-citations')
  end

  def import_ris
    authorize(@project)
    if params[:project].present? and params[:project][:citation_file].present?
      @project.import_citations_from_ris( params[:project][:citation_file] )
    end
    redirect_to edit_project_path(@project, anchor: 'panel-citations')
  end

  def import_endnote
    authorize(@project)
    if params[:project].present? and params[:project][:citation_file].present?
      @project.import_citations_from_enl( params[:project][:citation_file] )
    end
    redirect_to edit_project_path(@project, anchor: 'panel-citations')
  end

  def next_assignment
    authorize(@project)
    projects_user = ProjectsUser.where( project: @project, user: current_user ).first
    next_assignment = projects_user.assignments.first
    redirect_to controller: :assignments, action: :screen, id: next_assignment.id
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.includes(:extraction_forms)
                        .includes(:key_questions_projects)
                        .includes(:key_questions)
                        .includes(publishings: [{ user: :profile }, approval: [{ user: :profile }]])
                        .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project)
        .permit(:citation_file, :name, :description, :attribution, :methodology_description,
                :prospero, :doi, :notes, :funding_source,
                {tasks_attributes: [:id, :name, :num_assigned, :task_type_id, projects_users_role_ids:[]]},
                {citations_attributes: [:id, :name, :abstract, :pmid, :refman, :citation_type_id, :_destroy, author_ids: [], keyword_ids:[], journal_attributes: [:id, :name, :volume, :issue, :publication_date]]},
                {citations_projects_attributes: [:id, :_destroy, :citation_id, :project_id,
                                                citation_attributes: [:id, :_destroy, :name]]},
                key_questions_projects_attributes: [:id, :position], 
                projects_users_attributes: [:id, :_destroy, :user_id, role_ids: []])
    end

      def make_undo_link
        #!!! This is wrong. Just because there's an older version doesn't mean we should be able to revert to it.
      #    This could have been called when Assignment was created.
      if @project.versions.present?
        view_context.link_to '<u><strong>Undo that please!</strong></u>'.html_safe, undo_project_path(@project.versions.last), method: :post
      end
    end

    def make_redo_link
      params[:redo] == 'true' ? link = '<u><strong>Undo that please!</strong></u>'.html_safe : link = '<u><strong>Redo that please!</strong></u>'.html_safe
      view_context.link_to link, undo_project_path(@project_version.next, redo: !params[:redo]), method: :post
    end
end
