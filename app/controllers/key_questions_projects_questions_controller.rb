class KeyQuestionsProjectsQuestionsController < ApplicationController
  def create
    kqpq = KeyQuestionsProjectsQuestion.new(strong_params)
    authorize(kqpq)

    kqpq.save
    render json: kqpq, status: 200
  end

  def destroy
    kqpq = KeyQuestionsProjectsQuestion.find_by(strong_params)
    authorize(kqpq)

    kqpq.destroy
    render json: kqpq, status: 200
  end

  private

  def strong_params
    params
      .require(:key_questions_projects_question)
      .permit(:key_questions_project_id, :question_id)
  end
end
