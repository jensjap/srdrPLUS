module Api
  module V1
    class TagsController < BaseController
      before_action :set_projects_user, only: [ :index ]

      api :GET, '/v1/projects_users/:id/tags', 'List of tags a user has created'
      formats [:json]
      def index
        page          = ( params[ :page ] || 1 ).to_i
        page_size     = 100
        query         = params[ :q ] || ''
        projects_user_tags  = Tag.by_projects_user( @projects_user ).by_query( query )
        user_tags           = Tag.by_user( @projects_user.user ).by_query( query )
        lead_tags           = Tag.by_project_lead( @projects_user.project ).by_query( query )

        ## order is important, we want to show projects_users_tags first, then user_tags, then lead_tags
        combined_tags = ( projects_user_tags + user_tags + lead_tags ).uniq
        offset        = [ page_size * ( page - 1 ), combined_tags.length ].min

        paginated_tags = combined_tags[ offset .. offset + page_size - 1 ]
        @more = if offset + paginated_tags.length < combined_tags.length then true else false end 
        @projects_user_tags = []
        @user_tags = []
        @lead_tags = []

        paginated_tags.each do |tag|
          if projects_user_tags.include? tag
            @projects_user_tags << tag
          elsif user_tags.include? tag
            @user_tags << tag
          else
            @lead_tags << tag
          end
        end
      end


#
#
#        start_index = offset
#        end_index = offset + page_size - 1
#
#        @projects_user_tags = []
#        if start_index < projects_user_tags.length
#          @projects_user_tags = projects_user_tags[ start_index ... [ projects_user_tags.length, end_index ].min ] 
#        end
#        end_index = [ 0, ( end_index - projects_user_tags.length ) ].max
#        start_index = [ 0, ( start_index - projects_user_tags.length ) ].max
#
#        if start_index <  user_tags.length
#          @user_tags = user_tags[ start_index ... [ user_tags.length, end_index ].min ]
#        end
#        end_index = [ 0, ( end_index - user_tags.length ) ].max
#        start_index = [ 0, ( start_index - user_tags.length ) ].max
#
#        @lead_tags = []
#        if start_index <  lead_tags.length
#          @lead_tags = lead_tags[ start_index ... [ lead_tags.length, end_index ].min ]
#        end
#        end_index = [ 0, ( end_index - lead_tags.length ) ].max
#        start_index = [ 0, ( start_index - lead_tags.length ) ].max
#
#        @more = end_index > 0
#        render 'index.json'

      private
      def set_projects_user
        @projects_user = ProjectsUser.find( params[ :projects_user_id ] )
      end
    end
  end
end
