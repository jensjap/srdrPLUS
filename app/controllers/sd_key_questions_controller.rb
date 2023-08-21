class SdKeyQuestionsController < ApplicationController
  before_action :set_sd_key_question, only: [:destroy_with_picodts]

  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_key_question = SdKeyQuestion.new(sd_meta_datum:)
    sd_key_question.key_question = KeyQuestion.find_or_create_by!(name: params[:key_question_name] || 'New Key Question')
    sd_key_question.save!
    render json: { id: sd_key_question.id, name: sd_key_question.name, key_question: { id: nil, name: nil }, key_question_types: [] },
           status: 200
  end

  def update
    sd_key_question = SdKeyQuestion.find_by(id: params[:id])
    authorize(sd_key_question)
    sd_key_question.update!(sd_key_question_params)
    if params[:key_question_name]
      kq = KeyQuestion.find_or_create_by!(name: params[:key_question_name])
      sd_key_question.key_question = kq
      sd_key_question.save!
    end
    render json: sd_key_question.as_json, status: 200
  end

  def destroy
    sd_key_question = SdKeyQuestion.find_by(id: params[:id])
    authorize(sd_key_question)
    sd_key_question.destroy
    render json: { id: sd_key_question.id }, status: 200
  end

  def index
    @sd_key_questions = SdKeyQuestion
                        .joins(:key_question)
                        .where('key_questions.name like ?', "%#{params[:q]}%")
                        .where(sd_meta_datum_id: params['sd_meta_datum_id'])
  end

  def destroy_with_picodts
    sd_meta_datum = @sd_key_question.sd_meta_datum
    sd_picodts_ids = @sd_key_question.sd_picods.pluck :id
    SdKeyQuestion.transaction do
      SdPicod.where(id: sd_picodts_ids).destroy_all
      @sd_key_question.destroy
    end
    redirect_to(edit_sd_meta_datum_path(sd_meta_datum) + '?panel_number=3', status: 303)
  end

  def fuzzy_match
    fuzzy_match = SdKeyQuestion.find(params[:id]).fuzzy_match
    return nil unless fuzzy_match

    render json: { id: fuzzy_match.id, name: fuzzy_match.name }, status: 200
  end

  private

  def set_sd_key_question
    @sd_key_question = SdKeyQuestion.find params[:id]
  end

  def sd_key_question_params
    params.permit(:includes_meta_analysis)
  end
end
