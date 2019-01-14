module Api
  module V1
    class ProjectsUsersTermGroupsColorsTermsController < BaseController
      before_action :set_projects_user, only: [:destroy]

      api :DESTROY, '/v1/projects_users_term_groups_colors_terms/:id', 'Deletes specified projects_users_term_groups_colors_term'
      def destroy
        @projects_users_term_groups_colors_term.destroy
        head :no_content
      end

      api :CREATE, '/v1/projects_users_term_groups_colors_terms', 'Creates a new projects_users_term_groups_colors_term with specified projects_users_term_groups_color and term'
      def create
        strong_params = projects_users_term_groups_colors_term_params[:projects_users_term_groups_colors_term]
        term = Term.find_or_create_by(name: strong_params[:term_name])
        projects_users_term_groups_color = ProjectsUsersTermGroupsColor.find(strong_params['projects_users_term_groups_color_id'])
        @projects_users_term_groups_colors_term = ProjectsUsersTermGroupsColorsTerm.create(projects_users_term_groups_color: projects_users_term_groups_color, term: term)
        render json: { id: @projects_users_term_groups_colors_term.id }
      end

      api :PATCH, '/v1/projects_users_term_groups_colors/:id', 'Updates specified projects_users_term_groups_color with a new term'
      def update
        strong_params = projects_users_term_groups_colors_term_params[:projects_users_term_groups_colors_term]
        term = Term.find_or_create_by(name: strong_params[:term_name])
        @projects_users_term_groups_colors_term.update(term: term)
        render json: { id: @projects_users_term_groups_colors_term.id }
      end

      private
        def set_projects_users_term_groups_colors_term
          @projects_users_term_groups_color_term = ProjectsUsersTermGroupsColorsTerm.find(params[:id])
        end

        def projects_users_term_groups_colors_term_params
          params.require(:projects_users_term_groups_colors_term)
                .permit(:projects_users_term_groups_color_id, :term_name)
        end
    end
  end
end

