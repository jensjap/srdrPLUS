class Api::V2::QuestionsController < Api::V2::BaseController
  before_action :set_question, only: [:show]

  resource_description do
    short 'End-Points describing Question definitions. Questions are part of a section within an Extraction Form.'
    formats [:json]
  end

  api :GET, '/v2/questions/:id.json', 'Display complete question definition. Requires API Key.'
  param_group :resource_id, Api::V2::BaseController
  def show
    authorize(@question.project, policy_class: QuestionPolicy)
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end
end