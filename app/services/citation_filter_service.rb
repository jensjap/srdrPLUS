class CitationFilterService
  def initialize(project_id:)
    @project_id = project_id
    @filters = []
  end

  def filter_by_creator(creator_id:)
    @filters << -> { CitationsProject.where(project_id: @project_id, creator_id: creator_id).pluck(:id) }
    self
  end

  def filter_by_created_date(date:)
    start_time = date.beginning_of_day.utc
    end_time = date.end_of_day.utc
    @filters << -> { CitationsProject.where(project_id: @project_id, created_at: start_time..end_time).pluck(:id) }
    self
  end

  def filter_all_citations
    @filters << -> { CitationsProject.where(project_id: @project_id).pluck(:id) }
    self
  end

  def filter_with_abstract_screening_results
    @filters << -> { CitationsProject.joins(:abstract_screening_results)
                                     .where(project_id: @project_id)
                                     .distinct
                                     .pluck(:id) }
    self
  end

  def filter_without_abstract_screening_results
    @filters << -> { CitationsProject.left_joins(:abstract_screening_results)
                                      .where(project_id: @project_id, abstract_screening_results: { id: nil })
                                      .distinct
                                      .pluck(:id) }
    self
  end

  def results
    return [] if @filters.empty?

    @filters.map(&:call).reduce(:&)
  end

  def clear_filters
    @filters = []
    self
  end
end
