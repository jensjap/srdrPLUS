class FulltextScreeningResultsTagsController < ApplicationController
  def create
    fulltext_screening_result = FulltextScreeningResult.find(params[:fulltext_screening_result_id])
    authorize(fulltext_screening_result, :update?)

    tag = Tag.find_or_create_by(id: params[:tag_id])
    fulltext_screening_results_tag =
      FulltextScreeningResultsTag.find_or_create_by(
        fulltext_screening_result:, tag:
      )
    render json: fulltext_screening_results_tag, status: 200
  end

  def destroy
    fulltext_screening_results_tag = FulltextScreeningResultsTag.find(params[:id])
    authorize(fulltext_screening_results_tag)

    fulltext_screening_results_tag.destroy
    render json: fulltext_screening_results_tag, status: 200
  end
end
