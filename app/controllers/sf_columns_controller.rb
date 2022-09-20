class SfColumnsController < ApplicationController
  def create
    @sf_question = SfQuestion.find(params[:sf_question_id])
    respond_to do |format|
      format.json do
        @sf_question.sf_columns.create!
        render json: {}
      end
    end
  end

  def update
    @sf_column = SfColumn.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_column.update(params.permit(:name))
        render json: @sf_column
      end
    end
  end

  def destroy
    @sf_column = SfColumn.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_column.destroy
        render json: {}
      end
    end
  end
end
