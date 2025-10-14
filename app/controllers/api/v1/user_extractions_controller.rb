class Api::V1::UserExtractionsController < Api::V1::BaseController
  def index
    extractions = policy_scope(Extraction)
                  .includes(:project, citations_project: :citation)
                  .where.not(consolidated: true)
                  .limit(50)

    # Filter by search query if provided
    if params[:q].present?
      query = params[:q].downcase
      extractions = extractions.joins(citations_project: :citation)
                               .where('LOWER(citations.name) LIKE ? OR LOWER(projects.name) LIKE ? OR extractions.id = ?',
                                      "%#{query}%", "%#{query}%", query.to_i)
    end

    formatted_extractions = extractions.map do |extraction|
      {
        id: extraction.id,
        project_name: extraction.project.name,
        citation_name: extraction.citations_project&.citation&.name || 'No Citation',
        user_name: extraction.user&.username || 'Unassigned',
        display_text: "##{extraction.id}: #{extraction.citations_project&.citation&.name&.truncate(50) || 'No Citation'} (#{extraction.project.name})",
        url: "/extractions/#{extraction.id}/work"
      }
    end

    respond_with formatted_extractions
  end

  private

  def policy_scope(scope)
    ExtractionPolicy::Scope.new(current_user, scope).resolve
  end
end
