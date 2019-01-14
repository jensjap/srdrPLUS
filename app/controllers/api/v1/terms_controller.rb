module Api
  module V1
    class TermsController < BaseController
      before_action :set_projects_users_term_groups_color, only: [ :index ]

      api :GET, '/v1/projects_users_term_groups_colors/:id/terms', 'List of terms belonging to a particular projects_users_term_groups_color'
      def index
        @terms = @projects_users_term_groups_color.terms
      end

      private
        def set_projects_users_term_groups_color
          @projects_users_term_groups_color = ProjectsUsersTermGroupsColor.find( params[ :projects_users_term_groups_color_id ] )
        end
    end
  end
end
