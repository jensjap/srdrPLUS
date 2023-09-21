class AbstractScreeningResultsController < ApplicationController
  after_action :verify_authorized

  def update
    respond_to do |format|
      format.json do
        @abstract_screening_result = AbstractScreeningResult
                                     .includes(citations_project: :citation)
                                     .find(params[:id])
        authorize(@abstract_screening_result)
        case params[:submissionType]
        when 'label'
          @abstract_screening_result.update(asr_params)
        when 'notes'
          @abstract_screening_result.update_column(:notes, params[:asr][:notes])
        end
        render json: @abstract_screening_result
      end
    end
  end

  def show
    respond_to do |format|
      format.json do
        @abstract_screening_result = AbstractScreeningResult
                                     .includes(:user, citations_project: :citation)
                                     .find(params[:id])
        authorize(@abstract_screening_result)
        if params[:resolution_mode] == 'true'
          @screened_cps = AbstractScreeningResult
                          .includes(citations_project: :citation)
                          .where(abstract_screening: @abstract_screening_result.abstract_screening, privileged: true)
        else
          @screened_cps = AbstractScreeningResult
                          .includes(citations_project: :citation)
                          .where(user: current_user, abstract_screening: @abstract_screening_result.abstract_screening, privileged: false)
        end
        prepare_json_data
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        @abstract_screening_result = AbstractScreeningResult
                                     .includes(citations_project: :citation)
                                     .find(params[:id])
        authorize(@abstract_screening_result)
        @abstract_screening_result.destroy

        render json: @abstract_screening_result
      end
    end
  end

  private

  def prepare_custom_reasons
    @custom_reasons = ProjectsReason.reasons_object(@abstract_screening.project, ProjectsReason::ABSTRACT)
    selected_reasons_hash = {}
    @abstract_screening_result.abstract_screening_results_reasons.includes(:reason).each do |asrr|
      selected_reasons_hash[asrr.reason_id] = {
        selected_id: asrr.id,
        name: asrr.reason.name,
        included: false
      }
    end
    @custom_reasons.map! do |custom_reason|
      if (asrr = selected_reasons_hash[custom_reason[:reason_id]])
        custom_reason[:selected] = true
        custom_reason[:selected_id] = asrr[:selected_id]
        selected_reasons_hash[custom_reason[:reason_id]][:included] = true
      end
      custom_reason
    end
    selected_reasons_hash.each do |reason_id, asrr_hash|
      next if asrr_hash[:included]

      @custom_reasons << {
        id: nil,
        reason_id:,
        name: asrr_hash[:name],
        pos: nil,
        selected: true,
        selected_id: asrr_hash[:selected_id]
      }
    end
  end

  def prepare_custom_tags
    @custom_tags = ProjectsTag.tags_object(@abstract_screening.project, ProjectsTag::ABSTRACT)
    selected_tags_hash = {}
    @abstract_screening_result.abstract_screening_results_tags.includes(:tag).each do |asrt|
      selected_tags_hash[asrt.tag_id] = {
        selected_id: asrt.id,
        name: asrt.tag.name,
        included: false
      }
    end
    @custom_tags.map! do |custom_tag|
      if (asrt = selected_tags_hash[custom_tag[:tag_id]])
        custom_tag[:selected] = true
        custom_tag[:selected_id] = asrt[:selected_id]
        selected_tags_hash[custom_tag[:tag_id]][:included] = true
      end
      custom_tag
    end
    selected_tags_hash.each do |tag_id, asrt_hash|
      next if asrt_hash[:included]

      @custom_tags << {
        id: nil,
        tag_id:,
        name: asrt_hash[:name],
        pos: nil,
        selected: true,
        selected_id: asrt_hash[:selected_id]
      }
    end
  end

  def prepare_json_data
    @abstract_screening = @abstract_screening_result.abstract_screening

    prepare_custom_reasons
    prepare_custom_tags

    @all_labels =
      @abstract_screening_result.citations_project.abstract_screening_results.order(updated_at: :desc).map do |label|
        {
          updated_at: label.updated_at,
          label: label.label,
          user_handle: label.user.handle,
          privileged: label.privileged,
          tags: label.tags.map { |tag| tag['name'] }.join(', '),
          reasons: label.reasons.map { |reasons| reasons['name'] }.join(', '),
          notes: label.notes
        }
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
end
