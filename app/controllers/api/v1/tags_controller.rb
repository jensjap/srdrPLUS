module Api
  module V1
    class TagsController < BaseController
      before_action :set_assignment, only: [ :index ]

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

          ## order is important, we want to show projects_users_tags first, then user_tags, then lead_tags
          all_tags = ( lead_tags + projects_user_tags + user_tags ).uniq

        end

        offset      = [ page_size * ( page - 1 ), all_tags.length ].min
        @tags       = all_tags[ offset .. offset + page_size - 1 ]
        @more       = if offset + @tags.length < all_tags.length then true else false end
      end

      private
      def set_assignment
        @assignment = Assignment.find( params[ :assignment_id ] )
      end
    end
  end
end
