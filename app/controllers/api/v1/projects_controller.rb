module Api
  module V1
    class ProjectsController < BaseController
      before_action :set_project, only: [:show, :update, :destroy]

      SORT = {  'updated-at': { updated_at: :desc },
                'created-at': { created_at: :desc }
      }.stringify_keys

      def_param_group :project do
        param :project, Hash, required: true, action_aware: true do
          param :name,           String, 'Name of the project'
          param :funding_source, String, 'Who funds this project'
          param :prospero,       String, 'Prospero ID'
          param :doi,            String, 'Document Object Identifier'
          param :description,    String, 'Long description of project'
          param :attribution,    String, 'Project attribution'
          param :methodology,    String, 'Methodology description'
          param :notes,          String, 'Project notes'
        end
      end

      api :GET, '/v1/projects', 'List of projects'
      formats [:json]
      def index
        @projects = current_user.projects
          .includes(:extraction_forms)
          .includes(:key_questions)
          .includes(publishings: [{ user: :profile }, approval: [{ user: :profile }]])
          .by_query(@query).order(SORT[@order]).page(params[:page])
      end

      api :GET, '/v1/projects/:id', 'Show project by id'
      formats [:json]
      def show
        respond_with @project
      end

      api :POST, '/v1/projects', 'Create project'
      param_group :project
      formats ['json']
      def create
        @project = Project.new(project_params)
        flash[:notice] = 'Project was successfully created.' if @project.save
        respond_with @project
      end

      api :POST, '/v1/projects/:id', 'update project'
      param_group :project
      formats ['json']
      def update
        @project.update(project_params)
        flash[:notice] = 'Project was successfully updated.' if @project.save
        respond_with @project
      end

      private

        def set_project
          @project = Project.find(params[:id])
        end

        def project_params
          params.require(:project)
            .permit(:citation_file, :name, :description, :attribution, :methodology_description,
                    :prospero, :doi, :notes, :funding_source,
                    { tasks_attributes: [:id, :name, :num_assigned, :task_type_id, projects_users_role_ids:[]]},
                    { citations_attributes: [:id, :name, :abstract, :pmid, :refman, :citation_type_id, :_destroy, author_ids: [], keyword_ids:[], journal_attributes: [ :id, :name, :volume, :issue, :publication_date]] },
                    citations_projects_attributes: [ :id, :_destroy, :citation_id, :project_id,
                                                    citation_attributes: [:id, :_destroy, :name]])
        end
    end
  end
end
