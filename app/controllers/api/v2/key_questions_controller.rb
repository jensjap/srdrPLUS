class Api::V2::KeyQuestionsController < Api::V2::BaseController
  before_action :set_key_question, only: [:show]

  resource_description do
    short 'End-Points describe Key Questions.'
    formats [:json]
  end

  api :GET, '/v2/key_questions/:id.json'
  param_group :resource_id, Api::V2::BaseController
  def show
  end

  private
    def set_key_question
      @key_question = KeyQuestion.find(params[:id])
    end
end
