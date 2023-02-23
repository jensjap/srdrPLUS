class QuestionRowsController < ApplicationController
  before_action :set_question_row, :skip_policy_scope, only: [:destroy]

  def destroy
    @question = @question_row.question

    # Ensure that at least 1 row stays behind after deletion.
    if @question.question_rows.length > 1
      @question_row.destroy
      respond_to do |format|
        format.html { redirect_to edit_question_path(@question), notice: t('removed') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_question_path(@question), alert: t('requires_one') }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_question_row
    @question_row = QuestionRow.find(params[:id])
    authorize(@question_row)
  end
end
