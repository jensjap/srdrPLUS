class QuestionRowColumnsController < ApplicationController
  before_action :set_question_row_column, :skip_policy_scope,
                only: %i[destroy update destroy_entire_column answer_choices]

  def update
    respond_to do |format|
      format.json do
        if params.dig(:question_row_column_type, :name)
          question_row_column_type = QuestionRowColumnType.find_by(name: params[:question_row_column_type][:name])
          render json: {},
                 status: @question_row_column.update(question_row_column_type:) ? 200 : 422
        else
          render json: {},
                 status: @question_row_column.update(params.require(:question_row_column).permit(:name)) ? 200 : 422
        end
      end
    end
  end

  def create
    authorize(QuestionRow.find(params[:question_row_id]).question_row_columns.new)
    respond_to do |format|
      format.json do
        render json: {},
               status: QuestionRow.find(params[:question_row_id]).add_columns_to_all_siblings ? 200 : 422
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        render json: {},
               status: @question_row_column.remove_column_from_all_siblings ? 200 : 422
      end
    end
  end

  def destroy_entire_column
    @question = @question_row_column.question

    # Ensure that at least 1 column stays behind after deletion.
    if @question.question_rows.first.question_row_columns.length > 1
      QuestionRowColumn.transaction do
        destroy_all_question_row_columns_on_column_index
      end

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

  def answer_choices
    @answer_choices = @question_row_column.question_row_columns_question_row_column_options
                                          .where(question_row_column_option_id: 1)
                                          .by_query(params[:q])
  end

  private

  def set_question_row_column
    @question_row_column = QuestionRowColumn.find(params[:id])
    authorize(@question_row_column)
  end

  # This method will remove question_row_columns down all the rows
  # in the question. To find the index of the column to remove we use
  # the index of the @question_row_column on which the destroy/remove
  # request was triggered.
  def destroy_all_question_row_columns_on_column_index
    index_to_nuke = find_index_to_nuke

    # Iterate through each row and remove the question_row_column at
    # index column_index_to_nuke.
    @question.question_rows.each do |qr|
      qr.question_row_columns[index_to_nuke].destroy
    end
  end

  def find_index_to_nuke
    question_row_column_index_to_nuke = 0

    # Find the index of the question_row_column on which the
    # destroy/remove request was triggered.
    @question.question_rows.first.question_row_columns.each do |qrc|
      break if qrc == @question_row_column

      question_row_column_index_to_nuke += 1
    end

    question_row_column_index_to_nuke
  end
end
