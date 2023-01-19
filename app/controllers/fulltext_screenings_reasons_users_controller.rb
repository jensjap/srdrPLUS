class FulltextScreeningsReasonsUsersController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        name = params[:name]
        fulltext_screening_id = params[:fulltext_screening_id]
        reason = Reason.find_or_create_by!(name:)
        FulltextScreeningsReasonsUser.find_or_create_by!(fulltext_screening_id:, reason:, user: current_user)
        render json: {}, status: :ok
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        name = params[:newCustomValue]
        fulltext_screenings_reasons_user = FulltextScreeningsReasonsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        fulltext_screenings_reasons_user.update!(position: params[:position]) if params[:position]
        if name
          reason = Reason.find_or_create_by!(name:)
          fsrrs =
            FulltextScreeningResultsReason
            .joins(:reason, fulltext_screening_result: :fulltext_screening)
            .where(
              reason: fulltext_screenings_reasons_user.reason,
              fulltext_screening_result: {
                fulltext_screening_result: {
                  fulltext_screening: fulltext_screenings_reasons_user.fulltext_screening,
                  user_id: current_user.id
                }
              }
            )
          fsrrs.each { |fsrt| fsrt.update!(reason:) }
          fulltext_screenings_reasons_user.update!(reason:)
        end
        render json: {}, status: :ok
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        fulltext_screenings_reasons_user = FulltextScreeningsReasonsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        fulltext_screening = fulltext_screenings_reasons_user.fulltext_screening
        reason = fulltext_screenings_reasons_user.reason
        if params[:destroyExistingValues]
          FulltextScreeningResultsReason
            .joins(fulltext_screening_result: %i[fulltext_screening user])
            .where(
              reason:,
              fulltext_screening_result: { user: current_user, fulltext_screening: }
            ).destroy_all
        end
        fulltext_screenings_reasons_user.destroy!
        render json: {}, status: :ok
      end
    end
  end
end
