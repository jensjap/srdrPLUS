class QuestionsController < ApplicationController
  before_action :set_extraction_forms_projects_section, only: [:new, :create]

  # GET /extraction_forms_projects_sections/1/questions/new
  def new
    @question = @extraction_forms_projects_section.questions.new
  end

  # POST /extraction_forms_projects_section/1/questions
  # POST /extraction_forms_projects_section/1/questions.json
  def create
    @question = @extraction_forms_projects_section.questions.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                                      anchor: "panel-tab-#{ @extraction_forms_projects_section.id }"),
                                                                      notice: t('success') }
        format.json { render :show, status: :created, location: @extraction_forms_projects_section }
      else
        format.html { render :new }
        format.json { render json: @extraction_forms_projects_section.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_extraction_forms_projects_section
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:extraction_forms_projects_section_id])
  end

  def set_question
    @question = Question.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def question_params
    params.require(:question)
      .permit(:question_type_id,
              :name,
              :description)
  end
end
