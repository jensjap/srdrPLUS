class SdKeyQuestionsSdPicodsController < ApplicationController
  def create
    sd_picod = SdPicod.find(params[:sd_picod_id])
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    key_question = KeyQuestion.find_or_create_by(name: params[:name])
    authorize(sd_picod)
    sd_key_question = SdKeyQuestion.find_or_create_by(key_question:, sd_meta_datum:)
    sd_picod.sd_key_questions << sd_key_question unless sd_picod.sd_key_questions.include?(sd_key_question)
    render json: {}, status: 200
  end

  def destroy
    sd_picod = SdPicod.find(params[:sd_picod_id])
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_picod)
    key_question = KeyQuestion.find_by(name: params[:name])
    sd_key_question = SdKeyQuestion.find_by(key_question:, sd_meta_datum:) if key_question
    sd_picod.sd_key_questions.delete(sd_key_question) if key_question && sd_key_question
    render json: {}, status: 200
  end
end
