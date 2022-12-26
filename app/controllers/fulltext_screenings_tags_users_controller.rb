class FulltextScreeningsTagsUsersController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        name = params[:name]
        fulltext_screening_id = params[:fulltext_screening_id]
        tag = Tag.find_or_create_by!(name:)
        FulltextScreeningsTagsUser.find_or_create_by!(fulltext_screening_id:, tag:, user: current_user)
        render json: {}, status: :ok
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        name = params[:newCustomValue]
        fulltext_screenings_tags_user = FulltextScreeningsTagsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        fulltext_screenings_tags_user.update!(position: params[:position]) if params[:position]
        if name
          tag = Tag.find_or_create_by!(name:)
          fsrts =
            FulltextScreeningResultsTag
            .joins(:tag, fulltext_screening_result: :fulltext_screening)
            .where(
              tag: fulltext_screenings_tags_user.tag,
              fulltext_screening_result: {
                fulltext_screening_result: {
                  fulltext_screening: fulltext_screenings_tags_user.fulltext_screening,
                  user_id: current_user.id
                }
              }
            )
          fsrts.each { |fsrt| fsrt.update!(tag:) }
          fulltext_screenings_tags_user.update!(tag:)
        end
        render json: {}, status: :ok
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        fulltext_screenings_tags_user = FulltextScreeningsTagsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        fulltext_screening = fulltext_screenings_tags_user.fulltext_screening
        tag = fulltext_screenings_tags_user.tag
        if params[:destroyExistingValues]
          FulltextScreeningResultsTag
            .joins(fulltext_screening_result: %i[fulltext_screening user])
            .where(
              tag:,
              fulltext_screening_result: { user: current_user, fulltext_screening: }
            ).destroy_all
        end
        fulltext_screenings_tags_user.destroy!
        render json: {}, status: :ok
      end
    end
  end
end
