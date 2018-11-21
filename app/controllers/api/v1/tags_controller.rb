module Api
  module V1
    class TagsController < BaseController
<<<<<<< HEAD
      before_action :set_assignment, only: [ :index ]
=======
      before_action :set_projects_user, :skip_policy_scope, :skip_authorization, only: [ :index ]
>>>>>>> create and apply policies to reasons taggings tags timepoints_names type1s

      api :GET, '/v1/projects_users/:id/tags', 'List of tags a user has created'
      formats [:json]
      def index
        page          = ( params[ :page ] || 1 ).to_i
        page_size     = 100
        query         = params[ :q ] || ''
        all_tags      = []

        if @assignment.assignment_option_types.where( name: "ONLY_LEAD_TAGS" ).length > 0
          all_tags    = Tag.by_project_lead( @assignment.project ).by_query( query ) 
        else
          projects_user_tags  = Tag.by_projects_user( @assignment.projects_user ).by_query( query )
          user_tags           = Tag.by_user( @assignment.user ).by_query( query )
          lead_tags           = Tag.by_project_lead( @assignment.project ).by_query( query )

<<<<<<< HEAD
          ## order is important, we want to show projects_users_tags first, then user_tags, then lead_tags
          all_tags = ( lead_tags + projects_user_tags + user_tags ).uniq
=======
        paginated_tags = combined_tags[ offset .. offset + page_size - 1 ]
        @more = if offset + paginated_tags.length < combined_tags.length then true else false end
        @projects_user_tags = []
        @user_tags = []
        @lead_tags = []
>>>>>>> create and apply policies to reasons taggings tags timepoints_names type1s

        end

<<<<<<< HEAD
        offset      = [ page_size * ( page - 1 ), all_tags.length ].min
        @tags       = all_tags[ offset .. offset + page_size - 1 ]
        @more       = if offset + @tags.length < all_tags.length then true else false end
      end
=======
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
>>>>>>> create and apply policies to reasons taggings tags timepoints_names type1s

      private
      def set_assignment
        @assignment = Assignment.find( params[ :assignment_id ] )
      end
    end
  end
end
