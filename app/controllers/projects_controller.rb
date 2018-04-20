class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc }
  }.stringify_keys

  # GET /projects
  # GET /projects.json
  def index
    msg = Message.get_totd.check_message
    flash.now[:info] = msg if msg
    @query = params[:q]
    @order = params[:o] || 'updated-at'
    @projects = current_user.projects.includes(:extraction_forms)
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
    @citations = @project.citations
    @citations_projects = @project.citations_projects.page(params[:page])
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

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
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
    @projects = Project.includes(publishings: [{ user: :profile }, approval: [{ user: :profile }]])
                       .includes(:key_questions)
                       .by_name_description_and_query(@query).order(SORT[@order]).page(params[:page])
    render 'index'
  end

  def undo
    @project_version = PaperTrail::Version.find_by_id(params[:id])
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.includes(:extraction_forms)
                        .includes(:key_questions)
                        .includes(publishings: [{ user: :profile }, approval: [{ user: :profile }]])
                        .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project)
        .permit(:name, :description, :attribution, :methodology_description,
                :prospero, :doi, :notes, :funding_source,
                { tasks_attributes: [:id, :name, :num_assigned, :task_type_id, assignments_attributes: [:id, :user_id]]},
                { assignments_attributes: [:id, :done_so_far, :date_assigned, :date_due, :done, :user_id]},
                { citations_attributes: [:id, :name, :citation_type_id, :_destroy] },
                citations_projects_attributes: [:id, :_destroy, :citation_id, :project_id, 
                                                citation_attributes: [:id, :_destroy, :name]])
    end

    def make_undo_link
      view_context.link_to '<u><strong>Undo that please!</strong></u>'.html_safe, undo_path(@project.versions.last), method: :post
    end

    def make_redo_link
      params[:redo] == 'true' ? link = '<u><strong>Undo that please!</strong></u>'.html_safe : link = '<u><strong>Redo that please!</strong></u>'.html_safe
      view_context.link_to link, undo_path(@project_version.next, redo: !params[:redo]), method: :post
    end
end
