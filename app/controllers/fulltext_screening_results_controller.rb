class FulltextScreeningResultsController < ApplicationController
  def update
    respond_to do |format|
      format.json do
        @fulltext_screening_result = FulltextScreeningResult
                                     .includes(citations_project: :citation)
                                     .find(params[:id])
        authorize(@fulltext_screening_result)
        case params[:submissionType]
        when 'label'
          @fulltext_screening_result.update(fsr_params)
        when 'reasons_and_tags'
          handle_reasons_and_tags
        when 'notes'
          @fulltext_screening_result.update_column(:notes, params[:fsr][:notes])
        end
        render json: @fulltext_screening_result
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        @fulltext_screening_result = FulltextScreeningResult
                                     .includes(citations_project: :citation)
                                     .find(params[:id])
        authorize(@fulltext_screening_result)
        @screened_cps = FulltextScreeningResult
                        .includes(citations_project: :citation)
                        .where(user: current_user,
                               fulltext_screening: @fulltext_screening_result.fulltext_screening)
        prepare_json_data
      end
    end
  end

  private

  def handle_reasons_and_tags
    reasons_and_tags_params['custom_reasons'].each do |reason_object|
      if reason_object[:selected]
        FulltextScreeningResultsReason.find_or_create_by(reason_id: reason_object[:reason_id],
                                                         fulltext_screening_result: @fulltext_screening_result)
      else
        FulltextScreeningResultsReason.where(reason_id: reason_object[:reason_id],
                                             fulltext_screening_result: @fulltext_screening_result).destroy_all
      end
    end

    reasons_and_tags_params['custom_tags'].each do |tag_object|
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
    @custom_reasons = FulltextScreeningsReasonsUser.custom_reasons_object(@fulltext_screening, current_user)
    @custom_tags = FulltextScreeningsTagsUser.custom_tags_object(@fulltext_screening, current_user)

    @custom_reasons.map! do |custom_reason|
      custom_reason[:selected] = true if @fulltext_screening_result.reasons.any? do |reason|
                                           reason.id == custom_reason[:reason_id]
                                         end
      custom_reason
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
      custom_reasons: %i[id reason_id name pos selected],
      custom_tags: %i[id tag_id name pos selected]
    )
  end
end
