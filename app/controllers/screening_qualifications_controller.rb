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

          existing_sqs = citations_project.screening_qualifications.where(qualification_type:)
          if existing_sqs.present?
            existing_sqs.destroy_all
          else
            if (opposite_qualification = ScreeningQualification.opposite_qualification(qualification_type))
              citations_project.screening_qualifications.where(qualification_type: opposite_qualification).destroy_all
            end
            citations_project.screening_qualifications.find_or_create_by!(qualification_type:, user: current_user)
          end

          citations_project.abstract_screening_results.each(&:evaluate_screening_qualifications)
          citations_project.fulltext_screening_results.each(&:evaluate_screening_qualifications)
          citations_project.evaluate_screening_status

          results << { citations_project_id: citations_project.id,
                       screening_status: citations_project.screening_status,
                       abstract_qualification: citations_project.abstract_qualification,
                       fulltext_qualification: citations_project.fulltext_qualification,
                       extraction_qualification: citations_project.extraction_qualification }
        end

        render json: results
      end
    end
  end
end
