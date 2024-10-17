class CitationFilterService
  attr_reader :creators, :created_dates, :import_types, :import_tasks

  def initialize(project_id:)
    @project_id = project_id
    @filters = []
    @creators = calculate_creators
    @created_dates = calculate_created_dates
    @import_types = calculate_import_types
    @import_tasks = calculate_import_tasks_and_created_dates
  end

  def filter_by_creators(creator_ids:)
    creator_ids_filter = CitationsProject.where(project_id: @project_id, creator_id: creator_ids).pluck(:id)
    @filters << -> { creator_ids_filter }
    self
  end

  def filter_by_created_dates(dates:)
    date_filters = dates.map do |date|
      start_time = DateTime.parse(date).utc
      end_time = start_time.end_of_hour
      CitationsProject.where(project_id: @project_id, created_at: start_time..end_time).pluck(:id)
    end.flatten.uniq
    @filters << -> { date_filters }
    self
  end

  def filter_by_import_tasks(task_dates:)
    task_date_filters = []

    dates = task_dates - ['No Import']
    if dates.any?
      date_filters = dates.map do |date|
        start_time = DateTime.parse(date).utc
        CitationsProject.joins(:import)
                        .where(project_id: @project_id)
                        .where(imports: { created_at: start_time })
                        .pluck(:id)
      end.flatten
      task_date_filters += date_filters
    end

    if task_dates.include?('No Import')
      no_import_filters = CitationsProject.where(project_id: @project_id, import_id: nil).pluck(:id)
      task_date_filters += no_import_filters
    end

    @filters << -> { task_date_filters.uniq }
    self
  end

  def filter_by_import_types(import_types:)
    import_type_filters = CitationsProject.where(project_id: @project_id, import_type: import_types).pluck(:id)
    @filters << -> { import_type_filters }
    self
  end

  def filter_unassigned_abstract_screening
    unassigned_abstract_screening_filter = CitationsProject.where(project_id: @project_id, abstract_screening_id: nil).pluck(:id)
    @filters << -> { unassigned_abstract_screening_filter }
    self
  end

  def filter_unassigned_fulltext_screening
    unassigned_fulltext_screening_filter = CitationsProject.where(project_id: @project_id, fulltext_screening_id: nil).pluck(:id)
    @filters << -> { unassigned_fulltext_screening_filter }
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
    creator_ids = CitationsProject.left_outer_joins(:abstract_screening_distributions)
                                  .where(project_id: @project_id)
                                  .where(abstract_screening_distributions: { id: nil })
                                  .distinct
                                  .pluck(:creator_id)
    User.where(id: creator_ids).map do |user|
      { id: user.id, handle: user.handle }
    end
  end

  def calculate_created_dates
    CitationsProject.left_outer_joins(:abstract_screening_distributions)
                    .where(project_id: @project_id)
                    .where(abstract_screening_distributions: { id: nil })
                    .distinct
                    .pluck(Arel.sql("DATE_FORMAT(citations_projects.created_at, '%Y-%m-%d %H:00:00')"))
  end

  def calculate_import_types
    CitationsProject.left_outer_joins(:abstract_screening_distributions)
                    .where(project_id: @project_id)
                    .where(abstract_screening_distributions: { id: nil })
                    .distinct
                    .pluck(:import_type)
  end

  def calculate_import_tasks_and_created_dates
    citations_project_ids = CitationsProject.left_outer_joins(:abstract_screening_distributions)
                                            .where(project_id: @project_id)
                                            .where(abstract_screening_distributions: { id: nil })
                                            .pluck(:id)

    import_dates = Import.joins(:citations_projects)
                         .where(citations_projects: { id: citations_project_ids })
                         .distinct
                         .pluck(:created_at)

    has_no_import = CitationsProject.left_outer_joins(:abstract_screening_distributions)
                                    .where(project_id: @project_id, import_id: nil)
                                    .where(abstract_screening_distributions: { id: nil })
                                    .exists?
    if has_no_import
      import_dates << 'No Import'
    end

    import_dates.uniq
  end
end
