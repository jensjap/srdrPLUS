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
    @projects = Project.includes(publishings: [:publishable, { user: :profile }]).includes(approvals: [{ user: :profile }]).
                        by_query(@query).order(SORT[@order]).page(params[:page])
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
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to edit_project_path(@project), notice: 'Project was successfully created.' }
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
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
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
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /projects/filter
  # GET /projects/filter.json
  def filter
    @query = params[:q]  # Need @query for index partial.
    @order = params[:o]
    @projects = Project.includes(publishings: [:publishable, { user: :profile }]).includes(approvals: [{ user: :profile }]).
                        by_name_description_and_query(@query).order(SORT[@order]).page(params[:page])
    render 'index'
  end

  # GET /projects/:id/key_questions
  # GET /projects/:id/key_questions.json
#  def key_questions
#    @key_questions = @project.key_questions.by_query(params[:q])
#  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :description, :attribution, :methodology_description,
                                      :prospero, :doi, :notes, :funding_source,
                                      key_questions_attributes: [:id, :_destroy, :name],
                                      key_questions_projects_attributes: [:id, :_destroy, :key_question_id, key_question_attributes: [:id, :_destroy, :name]]
      )
    end
end
