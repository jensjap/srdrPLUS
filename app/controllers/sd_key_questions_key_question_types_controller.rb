class SdKeyQuestionsKeyQuestionTypesController < ApplicationController
  def create
    sd_key_question = SdKeyQuestion.find(params[:sd_key_question_id])
    authorize(sd_key_question)
    key_question_type = KeyQuestionType.find_or_create_by(name: params[:name])
    unless sd_key_question.key_question_types.include?(key_question_type)
      sd_key_question.key_question_types << key_question_type
    end
    render json: {}, status: 200
  end

  def destroy
    sd_key_question = SdKeyQuestion.find(params[:sd_key_question_id])
    authorize(sd_key_question)
    key_question_type = KeyQuestionType.find_by(name: params[:name])
    sd_key_question.key_question_types.delete(key_question_type) if key_question_type
    render json: {}, status: 200
  end
end
