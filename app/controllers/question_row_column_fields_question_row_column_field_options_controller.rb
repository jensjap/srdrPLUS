class QuestionRowColumnFieldsQuestionRowColumnFieldOptionsController < ApplicationController
  before_action :set_question_row_column_fields_question_row_column_field_option, :skip_policy_scope, only: [:destroy]

  # DELETE /question_row_column_fields_question_row_column_field_options/1
  # DELETE /question_row_column_fields_question_row_column_field_options/1.json
  def destroy
    authorize(@question_row_column_fields_question_row_column_field_option.question.project, policy_class: QuestionRowColumnFieldsQuestionRowColumnFieldOptionPolicy)
    @question_row_column_fields_question_row_column_field_option = @question_row_column_fields_question_row_column_field_option.destroy

    respond_to do |format|
      format.html { redirect_to edit_question_path(@question_row_column_fields_question_row_column_field_option.question), notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private

    def set_question_row_column_fields_question_row_column_field_option
      @question_row_column_fields_question_row_column_field_option = QuestionRowColumnFieldsQuestionRowColumnFieldOption.find(params[:id])
    end
end
