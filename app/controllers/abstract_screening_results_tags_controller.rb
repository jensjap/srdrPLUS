class AbstractScreeningResultsTagsController < ApplicationController
  def create
    abstract_screening_result = AbstractScreeningResult.find(params[:abstract_screening_result_id])
    authorize(abstract_screening_result)

    tag = Tag.find_or_create_by(id: params[:tag_id])
    abstract_screening_results_tag =
      AbstractScreeningResultsTag.find_or_create_by(
        abstract_screening_result:, tag:
      )
    render json: abstract_screening_results_tag, status: 200
  end

  def destroy
    abstract_screening_results_tag = AbstractScreeningResultsTag.find(params[:id])
    authorize(abstract_screening_results_tag)

    abstract_screening_results_tag.destroy
    render json: abstract_screening_results_tag, status: 200
  end
end
