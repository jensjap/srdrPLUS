class QuestionRowColumnsController < ApplicationController
  before_action :set_question_row_column, only: [:destroy]

  def destroy
    @question = @question_row_column.question
    @question_row_column.destroy
    respond_to do |format|
      format.html { redirect_to edit_question_path(@question), notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private

  def set_question_row_column
    @question_row_column = QuestionRowColumn.find(params[:id])
  end
end

