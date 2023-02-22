class Api::V1::CitationsController < Api::V1::BaseController
  before_action :skip_policy_scope, :skip_authorization

  def index
    page                      = (params[:page] || 1).to_i
    page_size                 = 1000
    offset                    = page_size * (page - 1)
    query                     = params[:q]

    @citation_project_dict    = {}
    @total_count              = 0
    @citations                = []
    @more                     = false

    if params[:project_id].present?
      project = Project.find(params[:project_id])
      total_arr = if query
                    project.citations.by_query(query)
                           .order(pmid: :desc)
                           .includes(:journal, :keywords)
                  else
                    project.citations
                           .order(pmid: :desc)
                           .includes(:journal, :keywords)
                  end
      citations_projects      = project.citations_projects.where(citation: total_arr)
      @total_count            = citations_projects.length
      @citation_project_dict  = Hash[*citations_projects.map { |c_p| [c_p.citation_id, c_p.id] }.flatten]
      @citations              = total_arr[offset..offset + page_size - 1]
      @more                   = offset + @citations.length < @total_count
    else
      citations = if query
                    Citation.by_query(query)
                  else
                    Citation.all
                  end
      @total_count            = citations.length
      @citations              = citations[offset..offset + page_size - 1]
      @more                   = offset + @citations.length < total_arr.length
    end
  end

  def titles
    page                      = (params[:page] || 1).to_i
    query                     = params[:q] || ''
    page_size = 30
    offset                    = page_size * (page - 1)
    total_arr                 = Citation.by_query(query)
    @total_count              = total_arr.length
    @citations                = total_arr[offset..offset + page_size - 1]
    @more                     = offset + @citations.length < @total_count
  end

  def project_citations_query
    project_id = params[:project_id]
    query = params[:q].try(:downcase)

    citation_pool = Project.includes(:citations).find_by(id: project_id).citations || []

    if query.present?
      citation_hash_pool = citation_pool.each_with_object({}) do |citation, citation_pool|
        citation_title_words = (citation.name || '').split(/@+/)
        fuzzy_winner = FuzzyMatch.new([citation.pmid, citation.refman,
                                       citation.authors] + citation_title_words).find(query) || ''
        citation_pool[citation] = fuzzy_winner
      end

      citation_matches = []

      10.times do
        fuzzy_grand_winner = FuzzyMatch.new(citation_hash_pool.values).find(query)

        round_matches = citation_hash_pool.select { |_citation, fuzzy_winner| fuzzy_winner == fuzzy_grand_winner }.keys
        citation_matches += round_matches
        round_matches.each { |round_match| citation_hash_pool.delete(round_match) }
      end

    else
      citation_matches = citation_pool
    end

    citation_results = citation_matches.map { |citation| { id: citation.id, text: citation.label_method } }

    render json: { results: citation_results }
  end
end
