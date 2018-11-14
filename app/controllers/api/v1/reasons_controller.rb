module Api
  module V1
    class ReasonsController < BaseController
      before_action :set_projects_user, only: [ :index ]

      def index
        @projects_user_reasons   = Reason.by_projects_user( @projects_user )
        @lead_reasons            = Reason.by_project_lead( @projects_user.project )
      end

      private
      def set_projects_user
        @projects_user = ProjectsUser.find( params[ :projects_user_id ] )
      end
    end 
  end
end
