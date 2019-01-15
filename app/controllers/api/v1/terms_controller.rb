module Api
  module V1
    class TermsController < BaseController
      before_action :set_projects_users_term_groups_color, only: [ :index ]

      api :GET, '/v1/projects_users_term_groups_colors/:id/terms', 'List of terms belonging to a particular projects_users_term_groups_color'
      def index
        page          = ( params[ :page ] || 1 ).to_i
        page_size     = 100
        query         = params[ :q ] || ''
        all_termsa    = []

        if @projects_users_term_groups_color.present?
          all_terms   = @projects_users_term_groups_color.terms.by_query( query )
        else
          all_terms   = Term.by_query( query )
        end

        offset        = [ page_size * ( page - 1 ), all_terms.length ].min
        @terms        = all_terms[ offset .. offset + page_size - 1 ]
        @more         = if offset + @terms.length < all_terms.length then true else false end
      end

      private
        def set_projects_users_term_groups_color
          if params[ :projects_users_term_groups_color_id ].present?
            @projects_users_term_groups_color = ProjectsUsersTermGroupsColor.find( params[ :projects_users_term_groups_color_id ] )
          end
        end
    end
  end
end
