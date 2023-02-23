class QuestionRowColumnsQuestionRowColumnOptionsController < ApplicationController
  before_action :set_question_row_columns_question_row_column_option, :skip_policy_scope, only: [:destroy]

  # DELETE /question_row_columns_question_row_column_options/1
  # DELETE /question_row_columns_question_row_column_options/1.json
  def destroy
    authorize(@question_row_columns_question_row_column_option)
    @question_row_columns_question_row_column_option = @question_row_columns_question_row_column_option.destroy

    respond_to do |format|
      format.html do
        redirect_to edit_question_path(@question_row_columns_question_row_column_option.question), notice: t('removed')
      end
      format.json { head :no_content }
    end
  end

  private

  def set_question_row_columns_question_row_column_option
    @question_row_columns_question_row_column_option = QuestionRowColumnsQuestionRowColumnOption.find(params[:id])
  end
end
