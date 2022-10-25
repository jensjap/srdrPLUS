class ScreeningQualificationsController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        qualification_type = params[:qualification_type]
        return unless ScreeningQualification::ALL_QUALIFICATIONS.include?(qualification_type)

        results = []
        params[:citations_project_ids].each do |citations_project_id|
          citations_project = CitationsProject.find_by(id: citations_project_id)
          next unless citations_project

          citations_project.screening_qualifications.where(qualification_type: ScreeningQualification.opposite_qualification(qualification_type)).destroy_all
          citations_project.screening_qualifications.find_or_create_by!(qualification_type:)
          citations_project.evaluate_screening_status
          results << { citations_project_id: citations_project.id,
                       screening_status: citations_project.screening_status }
        end

        render json: results
      end
    end
  end
end
