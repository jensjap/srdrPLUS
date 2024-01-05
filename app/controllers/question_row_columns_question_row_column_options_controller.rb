class QuestionRowColumnsQuestionRowColumnOptionsController < ApplicationController
  before_action :set_question_row_columns_question_row_column_option, :skip_policy_scope, only: %i[destroy update]

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

  def create
    @question_row_columns_question_row_column_option = QuestionRowColumn.find(params[:question_row_column_id]).question_row_columns_question_row_column_options.new(strong_params)
    authorize(@question_row_columns_question_row_column_option)
    respond_to do |format|
      format.json do
        render json: {},
               status: @question_row_columns_question_row_column_option.save ? 200 : 422
      end
    end
  end

  def update
    authorize(@question_row_columns_question_row_column_option)
    respond_to do |format|
      format.json do
        render json: {},
               status: @question_row_columns_question_row_column_option.update(strong_params) ? 200 : 422
      end
    end
  end

  private

  def set_question_row_columns_question_row_column_option
    @question_row_columns_question_row_column_option = QuestionRowColumnsQuestionRowColumnOption.find(params[:id])
  end

  def strong_params
    params.require(:question_row_columns_question_row_column_option).permit(:name, :question_row_column_option_id)
  end
end
