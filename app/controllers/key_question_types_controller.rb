class KeyQuestionTypesController < ApplicationController
  def index
    @key_question_types = KeyQuestionType.by_query(params[:q])
  end
end
