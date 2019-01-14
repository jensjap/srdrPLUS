module Api
  module V1
    class ProjectsUsersTermGroupsColorsController < BaseController
      before_action :set_projects_users_term_groups_color, only: [:destroy, :update]
      before_action :set_projects_user, only: [:index, :create]

      api :GET, '/v1/assignments/:id/projects_users_term_groups_colors', 'List of projects_users_term_groups_colors a user has created for a particular project'
      formats [:json]
      def index
        @projects_users_term_groups_colors = ProjectsUsersTermGroupsColor.where(projects_user: @projects_user)
      end

      api :DESTROY, '/v1/projects_users_term_groups_colors/:id', 'Deletes specified projects_users_term_groups_color'
      def destroy
        @projects_users_term_groups_color.destroy
        head :no_content
      end

      api :CREATE, '/v1/projects_users_term_groups_colors', 'Creates a new projects_users_term_groups_color with specified projects_user, term_group and color'
      def create
        term_group = TermGroup.find_or_create_by(name: putgc_params[:term_group_name])
        term_groups_color = TermGroupsColor.find_or_create_by(term_group: term_group, color: Color.find(putgc_params[:color_id]))
        @projects_users_term_groups_color = ProjectsUsersTermGroupsColor.create(projects_user: @projects_user, term_groups_color: term_groups_color)
        render json: { id: @projects_users_term_groups_color.id }
      end

      api :PATCH, '/v1/projects_users_term_groups_colors/:id', 'Updates specified projects_users_term_groups_color with a new term_groups_color'
      def update
        term_group = TermGroup.find_or_create_by(name: putgc_params[:term_group_name])
        term_groups_color = TermGroupsColor.find_or_create_by(term_group: term_group, color: Color.find(putgc_params[:color_id]))
        @projects_users_term_groups_color.update(term_groups_color: term_groups_color)
        render json: { id: @projects_users_term_groups_color.id }
      end

      private
        def set_projects_users_term_groups_color
          @projects_users_term_groups_color = ProjectsUsersTermGroupsColor.find(params[:id])
        end

        def set_projects_user
          @projects_user = Assignment.find(params[:assignment_id]).projects_user
        end

        def putgc_params
          params.require(:projects_users_term_groups_color)
                .permit(:projects_user_id, :term_group_name, :color_id)
        end
    end
  end
end
