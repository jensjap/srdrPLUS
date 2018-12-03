module Api
  module V1
    class ReasonsController < BaseController
      before_action :set_assignment, :skip_policy_scope, :skip_authorization, only: [ :index ]

      def index
        page          = ( params[ :page ] || 1 ).to_i
        page_size     = 100
        query         = params[ :q ] || ''

        all_reasons   = [ ]
        if @assignment.assignment_option_types.where( name: "ONLY_LEAD_REASONS" ).length > 0
          all_reasons = Reason.by_project_lead( @assignment.project ).by_query( query )
        else
          all_reasons = ( Reason.by_project_lead( @assignment.project ).by_query( query ) +
                          Reason.by_projects_user( @assignment.projects_user ).by_query( query ) ).distinct
        end
        offset        = [ page_size * ( page - 1 ), all_reasons.length ].min
        @reasons      = all_reasons[ offset .. offset + page_size - 1 ]
        @more         = if offset + @reasons.length < all_reasons.length then true else false end
      end

      private
      def set_assignment
        @assignment = Assignment.find( params[ :assignment_id ] )
      end
    end
  end
end
