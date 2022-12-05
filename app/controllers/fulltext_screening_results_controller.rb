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
    fulltext_screening = @fulltext_screening_result.fulltext_screening

    other_fsr_params['predefined_reasons'].merge(other_fsr_params['custom_reasons']).each do |name, value|
      reason = Reason.find_or_create_by!(name:)
      unless fulltext_screening.reasons.include?(reason)
        FulltextScreeningsReasonsUser
          .find_or_create_by!(
            reason:, user: current_user,
            fulltext_screening:
          )
      end
      if value
        FulltextScreeningResultsReason
          .find_or_create_by!(reason:, fulltext_screening_result: @fulltext_screening_result)
      else
        FulltextScreeningResultsReason
          .find_by(reason:, fulltext_screening_result: @fulltext_screening_result)&.destroy
      end
    end

    FulltextScreeningsReasonsUser.where(user: current_user, fulltext_screening:).each do |fsru|
      next if other_fsr_params['custom_reasons'].key?(fsru.reason.name)

      fsru.destroy
      FulltextScreeningResultsReason.find_by(reason: fsru.reason,
                                             fulltext_screening_result: @fulltext_screening_result)&.destroy
    end

    other_fsr_params['predefined_tags'].merge(other_fsr_params['custom_tags']).each do |name, value|
      tag = Tag.find_or_create_by!(name:)
      unless fulltext_screening.tags.include?(tag)
        FulltextScreeningsTagsUser
          .find_or_create_by!(
            tag:, user: current_user,
            fulltext_screening:
          )
      end
      if value
        FulltextScreeningResultsTag
          .find_or_create_by!(tag:, fulltext_screening_result: @fulltext_screening_result)
      else
        FulltextScreeningResultsTag
          .find_by(tag:, fulltext_screening_result: @fulltext_screening_result)&.destroy
      end
    end

    FulltextScreeningsTagsUser.where(user: current_user, fulltext_screening:).each do |fsru|
      next if other_fsr_params['custom_tags'].key?(fsru.tag.name)

      fsru.destroy
      FulltextScreeningResultsTag.find_by(tag: fsru.tag,
                                          fulltext_screening_result: @fulltext_screening_result)&.destroy
    end
  end

  def prepare_json_data
    @fulltext_screening = @fulltext_screening_result.fulltext_screening
    @predefined_reasons = @fulltext_screening.reasons_object
    @predefined_tags = @fulltext_screening.tags_object
    @custom_reasons = FulltextScreeningsReasonsUser.custom_reasons_object(@fulltext_screening, current_user)
    @custom_tags = FulltextScreeningsTagsUser.custom_tags_object(@fulltext_screening, current_user)

    @fulltext_screening_result.reasons.each do |reason|
      name = reason.name
      if @predefined_reasons.key?(name)
        @predefined_reasons[name] = true
      else
        @custom_reasons[name] = true
      end
    end

    @fulltext_screening_result&.tags&.each do |tag|
      name = tag.name
      if @predefined_tags.key?(name)
        @predefined_tags[name] = true
      else
        @custom_tags[name] = true
      end
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

  def other_fsr_params
    params.require(:fsr).permit(
      predefined_reasons: {},
      predefined_tags: {},
      custom_reasons: {},
      custom_tags: {}
    )
  end
end
