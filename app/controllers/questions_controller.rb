class QuestionsController < ApplicationController
  before_action :set_extraction_forms_projects_section, only: [:new, :create]
  before_action :set_question, only: [:edit, :update, :destroy]

#  # GET /questions/1/build
#  def build
#    respond_to do |format|
#      format.html { render 'questions/question_types/' + @question.question_type.name.parameterize.underscore }
#      format.json { render :show, status: :created, location: @question }

#      if @question.question_type == QuestionType.find(1)
#        format.html { redirect_to build_extraction_forms_project_path(@question.extraction_forms_project,
#                                                                      anchor: "panel-tab-#{ @question.extraction_forms_projects_section.id }"),
#                                                                      notice: t('success') }
#        format.json { render :show, status: :created, location: @question }
#      else
#        format.html { render 'questions/question_types/' + @question.question_type.name.parameterize.underscore }
#        format.json { render :show, status: :created, location: @question }
#      end

#      case @question.question_type
#      when QuestionType.find(1)  # Text
#        format.html { render 'questions/question_types/text' }
#        format.json { render :show, status: :created, location: @question }
#      when QuestionType.find(2)  # Checkbox
#        format.html { render 'questions/question_types/checkbox' }
#        format.json { render :show, status: :created, location: @question }
#      when QuestionType.find(3)  # Dropdown
#        format.html { render 'questions/question_types/dropdown' }
#        format.json { render :show, status: :created, location: @question }
#      when QuestionType.find(4)  # Radio
#        format.html { render 'questions/question_types/radio' }
#        format.json { render :show, status: :created, location: @question }
#      when QuestionType.find(5)  # Matrix Checkbox
#        format.html { render 'questions/question_types/matrix_checkbox' }
#        format.json { render :show, status: :created, location: @question }
#      when QuestionType.find(6)  # Matrix Dropdown
#        format.html { render 'questions/question_types/matrix_dropdown' }
#        format.json { render :show, status: :created, location: @question }
#      when QuestionType.find(7)  # Matrix Radio
#        format.html { render 'questions/question_types/matrix_radio' }
#        format.json { render :show, status: :created, location: @question }
#      else
#        raise 'Unknown QuestionType'
#      end
#    end
#  end

  # GET /extraction_forms_projects_sections/1/questions/new
  def new
    @question = @extraction_forms_projects_section.questions.new
  end

  # GET /extraction_forms_projects_sections/1/questions/edit
  def edit
  end

  # POST /extraction_forms_projects_section/1/questions
  # POST /extraction_forms_projects_section/1/questions.json
  def create
    @question = @extraction_forms_projects_section.questions.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to edit_question_path(@question),
                                                      notice: t('success') }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_patch_params)
        format.html { redirect_to build_extraction_forms_project_path(@question.extraction_forms_project,
                                                                      anchor: "panel-tab-#{ @question.extraction_forms_projects_section.id }"),
                                                                      notice: t('success') }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to build_extraction_forms_project_path(@question.extraction_forms_project,
                                                                    anchor: "panel-tab-#{ @question.extraction_forms_projects_section.id }"),
                                                                    notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_extraction_forms_projects_section
      @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:extraction_forms_projects_section_id])
    end

    def set_question
      @question = Question.includes(question_rows: [
                                    { question_row_columns: [
                                      { question_row_column_field: [:question_row_column_field_type, :question_row_column_field_options] }] }])
                          .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question)
        .permit(:question_type_id,
                :name,
                :description)
    end

    def question_patch_params
      params.require(:question)
        .permit(:name,
                :description, question_rows_attributes:
                                [:id, :name, question_row_columns_attributes:
                                               [:id, :name, question_row_column_field_attributes:
                                                              [:id, :question_row_column_field_type_id, question_row_column_field_options_attributes:
                                                                      [:id, :value]]]])
    end
end
