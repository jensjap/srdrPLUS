class SdKeyQuestionsProjectsController < ApplicationController
  def create
    sd_key_questions_project = SdKeyQuestionsProject.new(sd_key_questions_project_params)
    authorize(sd_key_questions_project)
    sd_key_questions_project.save!
    render json: {
      id: sd_key_questions_project.id,
      name: sd_key_questions_project.key_question.name,
      sd_key_question_id: sd_key_questions_project.sd_key_question_id,
      key_questions_project_id: sd_key_questions_project.key_questions_project_id
    }, status: 200
  end

  def destroy
    sd_key_questions_project = SdKeyQuestionsProject.find(params[:id])
    authorize(sd_key_questions_project)
    sd_key_questions_project.destroy
    render json: sd_key_questions_project.as_json, status: 200
  end

  private

  def sd_key_questions_project_params
    params.permit(
      :sd_key_question_id,
      :key_questions_project_id
    )
  end
end
