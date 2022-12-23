class AbstractScreeningsTagsUsersController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        name = params[:name]
        abstract_screening_id = params[:abstract_screening_id]
        tag = Tag.find_or_create_by!(name:)
        AbstractScreeningsTagsUser.find_or_create_by!(abstract_screening_id:, tag:, user: current_user)
        render json: {}, status: :ok
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        abstract_screenings_tags_user = AbstractScreeningsTagsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        abstract_screenings_tags_user.update(position: params[:position])
        render json: {}, status: :ok
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        abstract_screenings_tags_user = AbstractScreeningsTagsUser.find_or_create_by!(
          id: params[:id], user: current_user
        )
        abstract_screening = abstract_screenings_tags_user.abstract_screening
        tag = abstract_screenings_tags_user.tag
        if params[:destroyExistingValues]
          AbstractScreeningResultsTag
            .joins(abstract_screening_result: %i[abstract_screening user])
            .where(
              tag:,
              abstract_screening_result: { user: current_user, abstract_screening: }
            ).destroy_all
        end
        abstract_screenings_tags_user.destroy!
        render json: {}, status: :ok
      end
    end
  end
end
