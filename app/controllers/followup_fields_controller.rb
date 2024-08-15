class FollowupFieldsController < ApplicationController
  def destroy
    respond_to do |format|
      format.json do
        followup_field = FollowupField.find(params[:id])
        authorize(followup_field)
        followup_field.destroy
        render json: {}, status: 200
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find(params[:question_row_columns_question_row_column_option_id])
        followup_field = qrcqrco.build_followup_field
        authorize(followup_field)
        render json: {}, status: followup_field.save ? 200 : 403
      end
    end
  end
end
