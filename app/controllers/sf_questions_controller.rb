class SfQuestionsController < ApplicationController
  def create
    @screening_form = ScreeningForm.find(params[:screening_form_id])
    respond_to do |format|
      format.json do
        sf_question = @screening_form.sf_questions.create!
        sf_question.sf_rows.create!
        sf_question.sf_columns.create!
        render json: {}
      end
    end
  end

  def update
    @sf_question = SfQuestion.find(params[:id])
    respond_to do |format|
      format.json do
        if (poss = params[:pos_index])
          poss.each do |pos|
            SfQuestion.find(pos[:sf_question_id]).update(pos: pos[:pos])
          end
        else
          @sf_question.update(params.permit(:name, :description))
        end
        render json: @sf_question
      end
    end
  end

  def destroy
    @sf_question = SfQuestion.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_question.destroy
        render json: {}
      end
    end
  end
end
