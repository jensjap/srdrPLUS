class SearchesController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization, only: [:index]
  skip_before_action :authenticate_user!

  ACCEPTABLE_SEARCH_KEYS = %w[
    name description attribution authors_of_report
    methodology_description prospero doi notes funding_source
    refman pmid abstract
  ]

  def index
    @nav_buttons.push('search')
    @accepted_param_values = []
    search_fields = []

    search_params = params[:general_search] || params[:projects_search] || params[:citations_search] || []
    search_params.each do |k, v|
      if ACCEPTABLE_SEARCH_KEYS.include?(k) && v.present?
        @accepted_param_values << v
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
        where: { created_at: time_filter },
        fields: search_fields
      ).pluck(:id)
      process_project_search_results(project_ids)

    elsif params[:citations_search]
      citation_ids = Citation.search(@accepted_param_values.join(' '), fields: search_fields).pluck(:id)
      process_citation_search_results(citation_ids)
    end
  end

  private

  def process_project_search_results(project_ids)
    @projects = Project.where(id: project_ids).to_a
    ensure_project_results_are_public
    apply_more_advanced_filters
    @projects = Kaminari.paginate_array(@projects).page(params[:page] || 1).per(10)
  end

  def process_citation_search_results(citation_ids)
    @citations_projects = CitationsProject.where(citation_id: citation_ids).to_a
    ensure_citation_results_are_public
    @citations_projects = Kaminari.paginate_array(@citations_projects).page(params[:page] || 1).per(10)
  end

  def time_filter
    if params[:projects_search][:after].present?
      { gte: params[:projects_search][:after] }
    elsif params[:projects_search][:before].present?
      { lte: params[:projects_search][:before] }
    else
      {}
    end
  end

  def ensure_project_results_are_public
    @projects = Project
                .published
                .where(id: @projects.pluck(:id))
  end

  def ensure_citation_results_are_public
    @citations_projects = CitationsProject.joins(project: { publishing: :approval })
                                          .where(id: @citations_projects.pluck(:id))
  end

  def apply_more_advanced_filters
    member = params.dig(:projects_search, :member)
    if member.present?
      @projects = Project.joins(projects_users: { user: :profile })
                         .where(id: @projects.pluck(:id))
                         .where('profiles.username LIKE ?', "%#{member}%")
                         .distinct
    end

    arm = params.dig(:projects_search, :arm)
    if arm.present?
      @projects = Project.joins(extractions: { extractions_extraction_forms_projects_sections: :type1s })
                         .where('type1s.name = ?', arm)
                         .where(id: @projects.pluck(:id))
                         .distinct
    end

    outcome = params.dig(:projects_search, :outcome)
    if outcome.present?
      @projects = Project.joins(extractions: { extractions_extraction_forms_projects_sections: :type1s })
                         .where('type1s.name = ?', outcome)
                         .where(id: @projects.pluck(:id))
                         .distinct
    end
  end
end
