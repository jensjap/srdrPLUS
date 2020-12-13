class Api::V2::QuestionsController < Api::V2::BaseController
  before_action :set_question, only: [:show]

  resource_description do
    short 'Question definition. Questions are part of a section within an Extraction Form.'
    formats [:json]
  end

  def show
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end
end