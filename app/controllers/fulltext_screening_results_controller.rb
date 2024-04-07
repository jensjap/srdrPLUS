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
          if @fulltext_screening_result.privileged && @fulltext_screening_result.label&.zero?
            @fulltext_screening_result.touch
          end
        when 'notes', 'form_complete'
          @fulltext_screening_result.update_column(params[:submissionType], params[:fsr][params[:submissionType]])
          @fulltext_screening_result.reindex
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
                        .where(
                          fulltext_screening: @fulltext_screening_result.fulltext_screening,
                          privileged: params[:resolution_mode] == 'true'
                        )
        @screened_cps = @screened_cps.where(user: current_user) unless params[:resolution_mode] == 'true'
        prepare_json_data
      end
    end
  end

  private

  def prepare_custom_reasons
    @custom_reasons = ProjectsReason.reasons_object(@fulltext_screening.project, ProjectsReason::FULLTEXT)
    selected_reasons_hash = {}
    @fulltext_screening_result.fulltext_screening_results_reasons.includes(:reason).each do |fsrr|
      selected_reasons_hash[fsrr.reason_id] = {
        selected_id: fsrr.id,
        name: fsrr.reason.name,
        included: false
      }
    end
    @custom_reasons.map! do |custom_reason|
      if (fsrr = selected_reasons_hash[custom_reason[:reason_id]])
        custom_reason[:selected] = true
        custom_reason[:selected_id] = fsrr[:selected_id]
        selected_reasons_hash[custom_reason[:reason_id]][:included] = true
      end
      custom_reason
    end
    selected_reasons_hash.each do |reason_id, fsrr_hash|
      next if fsrr_hash[:included]

      @custom_reasons << {
        id: nil,
        reason_id:,
        name: fsrr_hash[:name],
        pos: nil,
        selected: true,
        selected_id: fsrr_hash[:selected_id]
      }
    end
  end

  def prepare_custom_tags
    @custom_tags = ProjectsTag.tags_object(@fulltext_screening.project, ProjectsTag::FULLTEXT)
    selected_tags_hash = {}
    @fulltext_screening_result.fulltext_screening_results_tags.includes(:tag).each do |fsrt|
      selected_tags_hash[fsrt.tag_id] = {
        selected_id: fsrt.id,
        name: fsrt.tag.name,
        included: false
      }
    end
    @custom_tags.map! do |custom_tag|
      if (fsrt = selected_tags_hash[custom_tag[:tag_id]])
        custom_tag[:selected] = true
        custom_tag[:selected_id] = fsrt[:selected_id]
        selected_tags_hash[custom_tag[:tag_id]][:included] = true
      end
      custom_tag
    end
    selected_tags_hash.each do |tag_id, fsrt_hash|
      next if fsrt_hash[:included]

      @custom_tags << {
        id: nil,
        tag_id:,
        name: fsrt_hash[:name],
        pos: nil,
        selected: true,
        selected_id: fsrt_hash[:selected_id]
      }
    end
  end

  def prepare_json_data
    @fulltext_screening = @fulltext_screening_result.fulltext_screening

    prepare_custom_reasons
    prepare_custom_tags

    @all_labels =
      @fulltext_screening_result.citations_project.fulltext_screening_results.order(updated_at: :desc).map do |label|
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

  def fsr_params
    params
      .require(:fsr)
      .permit(
        :label,
        :notes
      )
  end
end
