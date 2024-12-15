class CitationsController < ApplicationController
  before_action :set_project, only: %i[index]
  before_action :set_citation, only: %i[show edit update]

  before_action :skip_policy_scope
  before_action :skip_authorization

  def new
    @citation = Citation.new
    @citation.build_journal
    @citation.keywords.new
  end

  def create
    @citation = Citation.new(citation_params)
    respond_to do |format|
      if @citation.save
        format.html { redirect_to edit_citation_path(@citation), notice: t('success') }
        format.json { render :show, status: :created, location: @citation }
      else
        format.html { render :new }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize_access
    project_id = params.try(:[], :citation).try(:[], :project_id)
    respond_to do |format|
      if @citation.update(citation_params)
        format.html do
          if project_id.present?
            redirect_to project_citations_path(project_id), notice: 'Citation was successfully updated.'
          else
            redirect_to edit_citation_path(@citation), notice: 'Citation was successfully updated.'
          end
        end
        format.json { render :show, status: :ok, location: @citation }
      else
        format.html do
          if project_id
            redirect_to(edit_citation_path(@citation, project_id:), alert: @citation.errors.full_messages.join(', '))
          else
            redirect_to(edit_citation_path(@citation), alert: @citation.errors.full_messages.join(', '))
          end
        end
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize_access
    @project = Project.includes(citations_projects: :citation).find(params[:project_id])
    authorize(@project)
    @citation.build_journal unless @citation.journal.present?
  end

  def show
    render 'show'
  end

  def index
    respond_to do |format|
      format.html do
        @nav_buttons.push('project_info_dropdown','citation_pool', 'my_projects')
        @citations = @project
                     .citations
                     .select(:id, :name, :pmid, :registry_number, :accession_number, :doi, :other, :authors)
                     .order(:id)
        @citations_projects_dict = @project.citations_projects.map { |cp| [cp.citation_id, cp] }.to_h
        @key_questions_projects_array_for_select = @project.key_questions_projects_array_for_select
        @project.citations.build
      end
      format.json do
        @draw = params[:draw]
        @length = params[:length].to_i
        @start = params[:start].to_i
        @citations_projects = @project
                              .citations_projects
                              .joins(:citation)
        order_by = case params.dig(:order, '0', :column)
                   when '0'
                     'citations.pmid'
                   when '1'
                     'citations.refman'
                   when '2'
                     'citations.authors'
                   when '3'
                     'citations.name'
                   else
                     'citations_projects.id'
                   end

        @citations_projects = @citations_projects
                              .order("#{order_by} #{if params.dig(:order, '0', 'dir') == 'desc'
                                                      'desc'
                                                    else
                                                      'asc'
                                                    end}")
        unless params.dig(:search, :value).blank?
          @citations_projects = @citations_projects.where(
            '(lower(citations.name) LIKE :like OR
            lower(citations.authors) LIKE :like OR
            lower(citations.pmid) LIKE :like OR
            lower(citations.registry_number) LIKE :like OR
            lower(citations.accession_number) LIKE :like OR
            lower(citations.doi) LIKE :like OR
            lower(citations.other) LIKE :like
            )', like: "%#{params[:search][:value]}%"
          )
        end
      end
    end
  end

  private

  # a helper method that sets the current citation from id to be used with callbacks
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_citation
    @citation = Citation.includes(:journal)
                        .find(params[:id])
  end

  def citation_params
    params
      .require(:citation)
      .permit(
        :accession_number,
        :authors,
        :name,
        :citation_type_id,
        :pmid,
        :registry_number,
        :doi,
        :abstract,
        :page_number_start,
        :page_number_end,
        :_destroy,
        citations_attributes: %i[id name _destroy],
        citations_projects_attributes: %i[id refman other_reference creator_id import_type import_id],
        journal_attributes: %i[id name publication_date issue volume _destroy],
        keywords_attributes: %i[id name _destroy]
      )
  end

  def authorize_access
    return unless (current_user.projects & @citation.projects).empty?

    redirect_back(
      fallback_location: root_path,
      flash: { error: 'You are not authorized to update this citation.' },
      status: 303
    )
  end
end
