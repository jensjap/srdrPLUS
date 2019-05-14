class SdKeyQuestionsController < ApplicationController
  def fuzzy_match
    fuzzy_match = SdKeyQuestion.find(params[:id]).fuzzy_match
    return nil unless fuzzy_match
    render json: { id: fuzzy_match.id, name: fuzzy_match.name }, status: 200
  end
end
