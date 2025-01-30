class SearchesController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization, only: [:index]
  skip_before_action :authenticate_user!

  ACCEPTABLE_SEARCH_KEYS = %w[
    name
    description
    attribution
    authors_of_report
    methodology_description
    prospero
    doi
    notes
    funding_source
    refman
    pmid
    abstract
  ].freeze

  def index
    @nav_buttons.push('search')
    @accepted_param_values = []
    search_fields = []

    search_criteria = search_params[:general_search] || search_params[:projects_search] || search_params[:citations_search] || []
    search_criteria.each do |k, v|
      if ACCEPTABLE_SEARCH_KEYS.include?(k) && v.present?
        sanitized_value = ActiveRecord::Base.sanitize_sql_like(v)
        @accepted_param_values << sanitized_value
        search_fields << k
      end
    end

    if params[:general_search]
      project_ids = Project.search(@accepted_param_values.join(' ')).pluck(:id)
      process_project_search_results(project_ids)

      citation_ids = Citation.search(@accepted_param_values.join(' ')).pluck(:id)
      process_citation_search_results(citation_ids)

    elsif params[:projects_search]
      project_ids = Project.search(
        @accepted_param_values.join(' '),
        where: time_filter,
        fields: search_fields
      ).pluck(:id)
      process_project_search_results(project_ids)

    elsif params[:citations_search]
      citation_ids = Citation.search(@accepted_param_values.join(' '), fields: search_fields).pluck(:id)
      process_citation_search_results(citation_ids)
    end
  end

  private

  def search_params
    params.permit(
      general_search: ACCEPTABLE_SEARCH_KEYS,
      projects_search: ACCEPTABLE_SEARCH_KEYS + [:after, :before, :member, :arm, :outcome],
      citations_search: ACCEPTABLE_SEARCH_KEYS
    )
  end

  def process_project_search_results(project_ids)
    @projects = Project.where(id: project_ids).to_a
    ensure_project_results_are_public
    ensure_project_results_are_not_blacklisted
    apply_more_advanced_filters
    @projects = Kaminari.paginate_array(@projects).page(params[:page] || 1).per(10)
  end

  def process_citation_search_results(citation_ids)
    @citations_projects = CitationsProject.where(citation_id: citation_ids).to_a
    ensure_citation_results_are_public
    @citations_projects = Kaminari.paginate_array(@citations_projects).page(params[:page] || 1).per(10)
  end

  def time_filter
    after = params.dig(:projects_search, :after)
    before = params.dig(:projects_search, :before)
    filters = {}
    filters[:created_at] = { gte: after } if after.present?
    filters[:created_at] = { lte: before } if before.present?
    filters
  end

  def ensure_project_results_are_public
    @projects = Project.published.where(id: @projects.pluck(:id))
  end

  def ensure_project_results_are_not_blacklisted
    @projects = @projects.reject { |proj| proj.dei_blacklisted? }
  end

  def ensure_citation_results_are_public
    @citations_projects = CitationsProject.joins(project: { publishing: :approval })
                                          .where(id: @citations_projects.pluck(:id))
  end

  def apply_more_advanced_filters
    apply_member_filter if params.dig(:projects_search, :member).present?
    apply_arm_filter if params.dig(:projects_search, :arm).present?
    apply_outcome_filter if params.dig(:projects_search, :outcome).present?
  end

  def apply_member_filter
    member = ActiveRecord::Base.sanitize_sql_like(params[:projects_search][:member])
    @projects = Project.joins(projects_users: { user: :profile })
                       .where(id: @projects.pluck(:id))
                       .where('profiles.username LIKE ?', "%#{member}%")
                       .distinct
  end

  def apply_arm_filter
    arm = ActiveRecord::Base.sanitize_sql_like(params[:projects_search][:arm])
    @projects = Project.joins(extractions: { extractions_extraction_forms_projects_sections: :type1s })
                       .where('type1s.name = ?', arm)
                       .where(id: @projects.pluck(:id))
                       .distinct
  end

  def apply_outcome_filter
    outcome = ActiveRecord::Base.sanitize_sql_like(params[:projects_search][:outcome])
    @projects = Project.joins(extractions: { extractions_extraction_forms_projects_sections: :type1s })
                       .where('type1s.name = ?', outcome)
                       .where(id: @projects.pluck(:id))
                       .distinct
  end
end
