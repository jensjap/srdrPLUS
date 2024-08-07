class QuestionRowsController < ApplicationController
  before_action :set_question_row, :skip_policy_scope, only: %i[destroy duplicate update]

  def duplicate
    @question_row.duplicate
    respond_to do |format|
      format.json { render json: {}, status: 200 }
    end
  end

  def create
    @question_row = QuestionRow.new(question_id: params[:question_id])
    authorize(@question_row)
    respond_to do |format|
      format.json do
        render json: {}, status: @question_row.save ? 200 : 422
      end
    end
  end

  def update
    authorize(@question_row)
    respond_to do |format|
      format.json do
        render json: {}, status: @question_row.update(params.require(:question_row).permit(:name)) ? 200 : 422
      end
    end
  end

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
