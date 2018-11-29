class KeyQuestionsProjectsController < ApplicationController
  before_action :set_project, only: [:create]
  before_action :set_key_questions_project, only: [:edit, :update, :destroy]
  before_action :skip_policy_scope

  # GET /key_questions_projects/1/edit
  def edit
  end

  # POST /projects/1/key_questions_projects
  # POST /projects/1/key_questions_projects.json
  def create
    @key_questions_project = @project.key_questions_projects.build(key_questions_project_params)
    authorize(@project, policy_class: KeyQuestionsProjectPolicy)

    respond_to do |format|
      if @key_questions_project.save
        format.html { redirect_to edit_project_path(@project, anchor: 'panel-key-questions'),
                      notice: t('success') }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { redirect_to edit_project_path(@project, anchor: 'panel-key-questions'),
                      alert: t('blank') }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /key_questions_projects/1
  # PATCH/PUT /key_questions_projects/1.json
  def update
    respond_to do |format|
      if @key_questions_project.update(key_questions_project_params)
        format.html { redirect_to edit_project_path(@key_questions_project.project, anchor: 'panel-key-questions'),
                      notice: t('success') }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /key_questions_projects/1
  # DELETE /key_questions_projects/1.json
  def destroy
    @project = @key_questions_project.project
    @key_questions_project.destroy
    respond_to do |format|
      format.html { redirect_to edit_project_path(@project, anchor: 'panel-key-questions'),
                    notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
      authorize(@project, policy_class: KeyQuestionsProjectPolicy)
    end

    def set_key_questions_project
      @key_questions_project = KeyQuestionsProject.find(params[:id])
      authorize(@key_questions_project.project, policy_class: KeyQuestionsProjectPolicy)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_questions_project_params
      params.require(:key_questions_project)
        .permit(key_question_attributes: [:name])
    end
end
