class FulltextScreeningResultsController < ApplicationController
  def update
    respond_to do |format|
      format.json do
        @fulltext_screening_result = FulltextScreeningResult.find(params[:id])
        handle_reasons_and_tags
        @fulltext_screening_result.update(fsr_params)
        @screened_cps = FulltextScreeningResult.where(user: current_user,
                                                      fulltext_screening: @fulltext_screening_result.fulltext_screening)
        prepare_json_data
        render :show
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        @fulltext_screening_result = FulltextScreeningResult.find(params[:id])
        @screened_cps = FulltextScreeningResult.where(user: current_user,
                                                      fulltext_screening: @fulltext_screening_result.fulltext_screening)
        prepare_json_data
      end
    end
  end

  private

  def handle_reasons_and_tags
    reasons_and_tags_params['predefined_reasons'].concat(reasons_and_tags_params['custom_reasons']).each do |reason_object|
      if reason_object[:selected]
        FulltextScreeningResultsReason.find_or_create_by(reason_id: reason_object[:reason_id],
                                                         fulltext_screening_result: @fulltext_screening_result)
      else
        FulltextScreeningResultsReason.where(reason_id: reason_object[:reason_id],
                                             fulltext_screening_result: @fulltext_screening_result).destroy_all
      end
    end

    reasons_and_tags_params['predefined_tags'].concat(reasons_and_tags_params['custom_tags']).each do |tag_object|
      if tag_object[:selected]
        FulltextScreeningResultsTag.find_or_create_by(tag_id: tag_object[:tag_id],
                                                      fulltext_screening_result: @fulltext_screening_result)
      else
        FulltextScreeningResultsTag.where(tag_id: tag_object[:tag_id],
                                          fulltext_screening_result: @fulltext_screening_result).destroy_all
      end
    end
  end

  def prepare_json_data
    @fulltext_screening = @fulltext_screening_result.fulltext_screening
    @predefined_reasons = @fulltext_screening.reasons_object
    @predefined_tags = @fulltext_screening.tags_object
    @custom_reasons = FulltextScreeningsReasonsUser.custom_reasons_object(@fulltext_screening, current_user)
    @custom_tags = FulltextScreeningsTagsUser.custom_tags_object(@fulltext_screening, current_user)

    @predefined_reasons.map! do |predefined_reason|
      predefined_reason[:selected] = true if @fulltext_screening_result.reasons.any? do |reason|
                                               reason.id == predefined_reason[:reason_id]
                                             end
      predefined_reason
    end

    @custom_reasons.map! do |custom_reason|
      custom_reason[:selected] = true if @fulltext_screening_result.reasons.any? do |reason|
                                           reason.id == custom_reason[:reason_id]
                                         end
      custom_reason
    end

    @predefined_tags.map! do |predefined_tag|
      predefined_tag[:selected] = true if @fulltext_screening_result.tags.any? do |tag|
                                            tag.id == predefined_tag[:tag_id]
                                          end
      predefined_tag
    end

    @custom_tags.map! do |custom_tag|
      custom_tag[:selected] = true if @fulltext_screening_result.tags.any? { |tag| tag.id == custom_tag[:tag_id] }
      custom_tag
    end
  end

  def fsr_params
    params
      .require(:fsr)
      .permit(
        :label,
        :notes
      )
  end

  def reasons_and_tags_params
    params.require(:fsr).permit(
      predefined_reasons: %i[id reason_id name position selected],
      predefined_tags: %i[id tag_id name position selected],
      custom_reasons: %i[id reason_id name position selected],
      custom_tags: %i[id tag_id name position selected]
    )
  end
end
