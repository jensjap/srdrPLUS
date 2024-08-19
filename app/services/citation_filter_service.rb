class CitationFilterService
  attr_reader :creators, :created_dates

  def initialize(project_id:)
    @project_id = project_id
    @filters = []
    @creators = calculate_creators
    @created_dates = calculate_created_dates
  end

  def filter_by_creators(creator_ids:)
    creator_ids_filter = CitationsProject.where(project_id: @project_id, creator_id: creator_ids).pluck(:id)
    @filters << -> { creator_ids_filter }
    self
  end

  def filter_by_created_dates(dates:)
    date_filters = dates.map do |date|
      start_time = Date.parse(date).beginning_of_day.utc
      end_time = Date.parse(date).end_of_day.utc
      CitationsProject.where(project_id: @project_id, created_at: start_time..end_time).pluck(:id)
    end.flatten.uniq
    @filters << -> { date_filters }
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

  private

  def calculate_creators
    creator_ids = CitationsProject.where(project_id: @project_id).distinct.pluck(:creator_id)
    User.where(id: creator_ids).map do |user|
      { id: user.id, handle: user.handle }
    end
  end

  def calculate_created_dates
    CitationsProject.where(project_id: @project_id).distinct.pluck("DATE(created_at)").map(&:to_date)
  end
end
