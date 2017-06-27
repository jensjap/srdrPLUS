class QuestionRowColumnsController < ApplicationController
  before_action :set_question_row_column, only: [:destroy]

  def destroy
    @question = @question_row_column.question
    destroy_all_question_row_columns
    respond_to do |format|
      format.html { redirect_to edit_question_path(@question), notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private

    def set_question_row_column
      @question_row_column = QuestionRowColumn.find(params[:id])
    end

    def destroy_all_question_row_columns
      column_idx_to_nuke = 0

      @question.question_rows.first.question_row_columns.each do |qrc|
        break if qrc == @question_row_column
        column_idx_to_nuke += 1
      end

      @question.question_rows.each do |qr|
        qr.question_row_columns[column_idx_to_nuke].destroy
      end
    end
end

