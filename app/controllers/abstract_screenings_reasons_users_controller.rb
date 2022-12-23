class AbstractScreeningsReasonsUsersController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        name = params[:name]
        abstract_screening_id = params[:abstract_screening_id]
        reason = Reason.find_or_create_by!(name:)
        AbstractScreeningsReasonsUser.find_or_create_by!(abstract_screening_id:, reason:, user: current_user)
        render json: {}, status: :ok
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        abstract_screenings_reasons_user = AbstractScreeningsReasonsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        abstract_screenings_reasons_user.update(position: params[:position])
        render json: {}, status: :ok
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        abstract_screenings_reasons_user = AbstractScreeningsReasonsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        abstract_screening = abstract_screenings_reasons_user.abstract_screening
        reason = abstract_screenings_reasons_user.reason
        if params[:destroyExistingValues]
          AbstractScreeningResultsReason
            .joins(abstract_screening_result: %i[abstract_screening user])
            .where(
              reason:,
              abstract_screening_result: { user: current_user, abstract_screening: }
            ).destroy_all
        end
        abstract_screenings_reasons_user.destroy!
        render json: {}, status: :ok
      end
    end
  end
end
