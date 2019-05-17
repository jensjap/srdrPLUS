class SdKeyQuestionsController < ApplicationController
  def index
    @sd_key_questions = SdKeyQuestion.
      joins(:key_question).
      where('key_questions.name like ?', "%#{params[:q]}%").
      where(sd_meta_datum_id: params['sd_meta_datum_id'])
  end

  def fuzzy_match
    fuzzy_match = SdKeyQuestion.find(params[:id]).fuzzy_match
    return nil unless fuzzy_match
    render json: { id: fuzzy_match.id, name: fuzzy_match.name }, status: 200
  end
end
