module Api
  module V1
    class TagsController < BaseController
      before_action :set_projects_user, only: [ :index ]
      api :GET, '/v1/user/:id/tags', 'List of tags a user has created'
      formats [:json]

      def index
        page          = ( params[ :page ] || 1 ).to_i
        page_size     = 40
        offset        = page_size * ( page - 1 )
        query         = params[ :q ] || ''
        projects_user_tags          = @projects_user.tags.by_query( query ).uniq
        user_tags = @projects_user.user.tags.by_query( query ).uniq
        lead_tags = []
        @projects_user.project.projects_users_roles.where( role: Role.find_by( name: "Leader" ) ).each do |project_lead|
          lead_tags += project_lead.tags.by_query( query ).to_a
        end
        lead_tags = lead_tags.uniq

        start_index = offset
        end_index = offset + page_size - 1

        @projects_user_tags = []
        if start_index < projects_user_tags.length
          @projects_user_tags = projects_user_tags[ start_index ... [ projects_user_tags.length, end_index ].min ] 
        end
        end_index = [ 0, ( end_index - projects_user_tags.length ) ].max
        start_index = [ 0, ( start_index - projects_user_tags.length ) ].max

        @user_tags = []
        if start_index <  user_tags.length
          @user_tags = user_tags[ start_index ... [ user_tags.length, end_index ].min ]
        end
        end_index = [ 0, ( end_index - user_tags.length ) ].max
        start_index = [ 0, ( start_index - user_tags.length ) ].max

        @lead_tags = []
        if start_index <  lead_tags.length
          @lead_tags = lead_tags[ start_index ... [ lead_tags.length, end_index ].min ]
        end
        end_index = [ 0, ( end_index - lead_tags.length ) ].max
        start_index = [ 0, ( start_index - lead_tags.length ) ].max

        byebug

        @more = end_index > 0
        render 'index.json'
      end

    private
      def set_projects_user
        @projects_user = ProjectsUser.find( params[ :projects_user_id ] )
      end
    end
  end
end
