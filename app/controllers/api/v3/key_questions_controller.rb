class Api::V3::KeyQuestionsController < Api::V3::BaseController
  before_action :set_project, only: [:index]

  def index
    authorize(@project, policy_class: KeyQuestionPolicy)
    @key_questions = KeyQuestionSupplyingService.new.find_by_project_id(@project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @key_questions }
      format.fhir_json { render json: @key_questions }
      format.html { render json: @key_questions }
      format.json { render json: @key_questions }
      format.xml { render xml: @key_questions }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  def show
    @key_question = KeyQuestionSupplyingService.new.find_by_key_question_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @key_question }
      format.fhir_json { render json: @key_question }
      format.html { render json: @key_question }
      format.json { render json: @key_question }
      format.xml { render xml: @key_question }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
