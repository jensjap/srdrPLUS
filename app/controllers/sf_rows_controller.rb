class SfRowsController < ApplicationController
  def create
    @sf_question = SfQuestion.find(params[:sf_question_id])
    respond_to do |format|
      format.json do
        @sf_question.sf_rows.create!
        render json: {}
      end
    end
  end

  def update
    @sf_row = SfRow.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_row.update(params.permit(:name))
        render json: @sf_row
      end
    end
  end

  def destroy
    @sf_row = SfRow.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_row.destroy
        render json: {}
      end
    end
  end
end
