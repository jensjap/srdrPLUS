class SdKeyQuestionsController < ApplicationController
  before_action :set_sd_key_question, only: [:destroy_with_picodts]

  def index
    @sd_key_questions = SdKeyQuestion.
      joins(:key_question).
      where('key_questions.name like ?', "%#{params[:q]}%").
      where(sd_meta_datum_id: params['sd_meta_datum_id'])
  end

  def destroy_with_picodts
    sd_meta_datum = @sd_key_question.sd_meta_datum
    sd_picodts_ids = @sd_key_question.sd_picods.pluck :id
    SdKeyQuestion.transaction do
      SdPicod.where(id: sd_picodts_ids).destroy_all
      @sd_key_question.destroy
    end
    redirect_to edit_sd_meta_datum_path(sd_meta_datum) + '?panel_number=3'
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
end
