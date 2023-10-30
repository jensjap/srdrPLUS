class QuestionsController < ApplicationController
  before_action :set_extraction_forms_projects_section, only: %i[
    new create
  ]
  before_action :set_question, only: %i[
    edit update destroy add_column add_row dependencies
    toggle_dependency duplicate
  ]
  before_action :skip_policy_scope

  # before_action :ensure_matrix_type, only: [:add_column, :add_row]

  # GET /extraction_forms_projects_sections/1/questions/new
  def new
    @question = @extraction_forms_projects_section.questions.new
    authorize(@question)
  end

  # GET /extraction_forms_projects_sections/1/questions/edit
  def edit
    @project = @question.project
    @extractions = @project.extractions
    render layout: !(params[:partial] == 'true')
  end

  # POST /extraction_forms_projects_section/1/questions
  # POST /extraction_forms_projects_section/1/questions.json
  def create
    @question = @extraction_forms_projects_section.questions.new(question_params)
    authorize(@question)

    # !!! Check for params 'q_type' and build values based on the type.
    respond_to do |format|
      if @question.save
        format.html do
          redirect_to edit_question_path(@question),
                      notice: t('success')
        end
        format.json { render json: { id: @question.id }, status: 200 }
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
        format.html do
          redirect_to build_extraction_forms_project_path(@question.extraction_forms_project,
                                                          'panel-tab': @question.extraction_forms_projects_section.id), notice: t('success')
        end
        format.js   { head :no_content }
        format.json { render json: { ok: 123 }, status: 200 }
      else
        format.html { render :edit }
        format.js   { head :no_content }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html do
        redirect_to build_extraction_forms_project_path(
          @question.extraction_forms_project,
          'panel-tab': @question.extraction_forms_projects_section.id
        ),
                    notice: t('removed')
      end
      format.json { head :no_content }
    end
  end

  # POST /questions/1/add_column
  # POST /questions/1/add_column.json
  def add_column
    @question.question_rows.each do |qr|
      qr.question_row_columns.create(
        question_row_column_type: QuestionRowColumnType.find_by(name: 'text')
      )
    end
    respond_to do |format|
      format.html do
        redirect_to edit_question_path(@question), notice: t('success')
      end
      format.json do
        render json: {}, status: 200
      end
    end
  end

  # POST /questions/1/add_row
  # POST /questions/1/add_row.json
  def add_row
    @question.question_rows.create
    @question.save

    respond_to do |format|
      format.html do
        redirect_to edit_question_path(@question), notice: t('success')
      end
      format.json do
        render json: {}, status: 200
      end
    end
  end

  def dependencies
    @extraction_forms_projects_section = @question.extraction_forms_projects_section
    @other_extraction_forms_projects_section_questions = @extraction_forms_projects_section.questions.reject do |q|
      q == @question
    end
    render layout: !(params[:partial] == 'true')
  end

  def toggle_dependency
    @prerequisitable = params[:question][:prerequisitable_type].constantize.find(params[:question][:prerequisitable_id].to_i)
    @question.toggle_dependency(@prerequisitable)

    respond_to do |format|
      format.js
      format.html { redirect_to dependencies_question_path(@question), notice: t('success') }
    end
  end

  def duplicate
    @duplicated_question = @question.duplicate
    redirect_to(edit_question_path(@duplicated_question), notice: t('success'), status: 303)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_extraction_forms_projects_section
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:extraction_forms_projects_section_id])
  end

  def set_question
    @question = Question.includes(question_rows: [
                                    { question_row_columns: [{ question_row_columns_question_row_column_options: [:followup_field] },
                                                             :question_row_column_options, :question_row_column_fields] }
                                  ])
                        .find(params[:id])
    authorize(@question)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def question_params
    params.require(:question)
          .permit(:name,
                  :description,
                  key_questions_project_ids: [])
  end

  def question_patch_params
    params.require(:question)
          .permit(:name,
                  :description,
                  key_questions_project_ids: [],
                  question_rows_attributes: [:id, :name, { question_row_columns_attributes:
                                             [:id, :question_row_column_type_id, :name, { question_row_columns_question_row_column_options_attributes:
                                              %i[id _destroy question_row_column_option_id name includes_followup] }] }])
  end

  #    def ensure_matrix_type
  #      redirect_to root_url, notice: 'Your action is not allowed' unless @question.question_type.name.include?('Matrix')
  #    end
end
