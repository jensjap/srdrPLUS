class AbstractScreeningResultsController < ApplicationController
  def update
    respond_to do |format|
      format.json do
        @abstract_screening_result = AbstractScreeningResult.find(params[:id])
        handle_reasons_and_tags
        @abstract_screening_result.update(asr_params)
        @screened_cps = AbstractScreeningResult.where(user: current_user,
                                                      abstract_screening: @abstract_screening_result.abstract_screening)
        prepare_json_data
        render :show
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        @abstract_screening_result = AbstractScreeningResult.find(params[:id])
        @screened_cps = AbstractScreeningResult.where(user: current_user,
                                                      abstract_screening: @abstract_screening_result.abstract_screening)
        prepare_json_data
      end
    end
  end

  private

  def handle_reasons_and_tags
    abstract_screening = @abstract_screening_result.abstract_screening

    other_asr_params['predefined_reasons'].merge(other_asr_params['custom_reasons']).each do |name, value|
      reason = Reason.find_or_create_by!(name:)
      unless abstract_screening.reasons.include?(reason)
        AbstractScreeningsReasonsUser
          .find_or_create_by!(
            reason:, user: current_user,
            abstract_screening:
          )
      end
      if value
        AbstractScreeningResultsReason
          .find_or_create_by!(reason:, abstract_screening_result: @abstract_screening_result)
      else
        AbstractScreeningResultsReason
          .find_by(reason:, abstract_screening_result: @abstract_screening_result)&.destroy
      end
    end

    AbstractScreeningsReasonsUser.where(user: current_user, abstract_screening:).each do |asru|
      next if other_asr_params['custom_reasons'].key?(asru.reason.name)

      asru.destroy
      AbstractScreeningResultsReason.find_by(reason: asru.reason,
                                             abstract_screening_result: @abstract_screening_result)&.destroy
    end

    other_asr_params['predefined_tags'].merge(other_asr_params['custom_tags']).each do |name, value|
      tag = Tag.find_or_create_by!(name:)
      unless abstract_screening.tags.include?(tag)
        AbstractScreeningsTagsUser
          .find_or_create_by!(
            tag:, user: current_user,
            abstract_screening:
          )
      end
      if value
        AbstractScreeningResultsTag
          .find_or_create_by!(tag:, abstract_screening_result: @abstract_screening_result)
      else
        AbstractScreeningResultsTag
          .find_by(tag:, abstract_screening_result: @abstract_screening_result)&.destroy
      end
    end

    AbstractScreeningsTagsUser.where(user: current_user, abstract_screening:).each do |astu|
      next if other_asr_params['custom_tags'].key?(astu.tag.name)

      astu.destroy
      AbstractScreeningResultsTag.find_by(tag: astu.tag,
                                          abstract_screening_result: @abstract_screening_result)&.destroy
    end
  end

  def prepare_json_data
    @abstract_screening = @abstract_screening_result.abstract_screening
    @predefined_reasons = @abstract_screening.reasons_object
    @predefined_tags = @abstract_screening.tags_object
    @custom_reasons = AbstractScreeningsReasonsUser.custom_reasons_object(@abstract_screening, current_user)
    @custom_tags = AbstractScreeningsTagsUser.custom_tags_object(@abstract_screening, current_user)

    @abstract_screening_result.reasons.each do |reason|
      name = reason.name
      if @predefined_reasons.key?(name)
        @predefined_reasons[name] = true
      else
        @custom_reasons[name] = true
      end
    end

    @abstract_screening_result&.tags&.each do |tag|
      name = tag.name
      if @predefined_tags.key?(name)
        @predefined_tags[name] = true
      else
        @custom_tags[name] = true
      end
    end
  end

  def asr_params
    params
      .require(:asr)
      .permit(
        :label,
        :notes
      )
  end

  def other_asr_params
    params.require(:asr).permit(
      predefined_reasons: {},
      predefined_tags: {},
      custom_reasons: {},
      custom_tags: {}
    )
  end
end
