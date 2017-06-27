class QuestionRowsController < ApplicationController
  before_action :set_question_row, only: [:destroy]

  def destroy
    @question = @question_row.question
    @question_row.destroy
    respond_to do |format|
      format.html { redirect_to edit_question_path(@question), notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private

    def set_question_row
      @question_row = QuestionRow.find(params[:id])
    end
end
