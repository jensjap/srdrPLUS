class CitationsController < ApplicationController
  before_action :set_project, only: %i[index]
  before_action :set_citation, only: %i[show edit update destroy]

  before_action :skip_policy_scope
  before_action :skip_authorization

  def new
    @citation = Citation.new
    @citation.authors.new
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
        format.html { redirect_to(edit_citation_path(@citation), alert: 'There was an issue') }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize_access
    @citation.build_journal unless @citation.journal.present?
  end

  def destroy
    authorize_access
    @citation.destroy
    respond_to do |format|
      format.html { redirect_to citations_url, notice: t('removed') }
      format.json { head :no_content }
    end
  end

  def show
    render 'show'
  end

  def index
    @nav_buttons.push('citation_pool', 'my_projects')
    @citations = @project
                 .citations
                 .select(:id, :refman, :name, :pmid, :registry_number, :accession_number, :doi, :other)
                 .includes(authors_citations: %i[ordering author])
                 .order(:id)
    @citations_projects_dict = @project.citations_projects.map { |cp| [cp.citation_id, cp] }.to_h
    @key_questions_projects_array_for_select = @project.key_questions_projects_array_for_select
  end

  private

  # a helper method that sets the current citation from id to be used with callbacks
  def set_project
    @project = Project.includes(citations_projects: :citation).find(params[:project_id])
  end

  def set_citation
    @citation = Citation.includes(:journal)
                        .find(params[:id])
  end

  def citation_params
    params.require(:citation)
          .permit(:accession_number, :name, :citation_type_id, :pmid, :registry_number, :refman, :doi, :other, :abstract, :page_number_start, :page_number_end, :_destroy,
                  citations_attributes: %i[id name _destroy],
                  journal_attributes: %i[id name publication_date issue volume _destroy],
                  authors_citations_attributes: [:id, :name, :_destroy, { author_attributes: %i[name id _destroy] }, { ordering_attributes: :position }],
                  keywords_attributes: %i[id name _destroy])
  end

  def authorize_access
    if (current_user.projects & @citation.projects).empty?
      flash[:error] = 'You are not authorized to update this citation'
      redirect_to(request.referrer || root_path)
    end
  end
end
