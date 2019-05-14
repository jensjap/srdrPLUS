class KeyQuestionsController < ApplicationController
  def index
    @key_questions = KeyQuestion.by_query(params[:q])
  end
end
