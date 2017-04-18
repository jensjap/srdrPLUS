class KeyQuestionsController < ApplicationController
  before_action :set_project, only: [:index, :new, :create]
  before_action :set_key_question, only: [:show, :edit, :update, :destroy]

  # GET /key_questions
  # GET /key_questions.json
  def index
    @key_questions = @project.key_questions
  end

  # GET /key_questions/1
  # GET /key_questions/1.json
  def show
  end

  # GET /key_questions/new
  def new
    @key_question = @project.key_questions.new
  end

  # GET /key_questions/1/edit
  def edit
  end

  # POST /key_questions
  # POST /key_questions.json
  def create
    @key_question = @project.key_questions.new(key_question_params)

    respond_to do |format|
      if @key_question.save
        format.html { redirect_to @key_question, notice: 'Key question was successfully created.' }
        format.json { render :show, status: :created, location: @key_question }
      else
        format.html { render :new }
        format.json { render json: @key_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /key_questions/1
  # PATCH/PUT /key_questions/1.json
  def update
    respond_to do |format|
      if @key_question.update(key_question_params)
        format.html { redirect_to @key_question, notice: 'Key question was successfully updated.' }
        format.json { render :show, status: :ok, location: @key_question }
      else
        format.html { render :edit }
        format.json { render json: @key_question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /key_questions/1
  # DELETE /key_questions/1.json
  def destroy
    @key_question.destroy
    respond_to do |format|
      format.html { redirect_to key_questions_url, notice: 'Key question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_key_question
      @key_question = KeyQuestion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def key_question_params
      params.require(:key_question).permit(:name)
    end
end
