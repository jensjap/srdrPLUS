module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [:screen, :history]

      api :GET, '/v1/assignments/:id/screen', 'List of citations to screen'
      formats [:json]
      def screen
        @unlabeled_citations_projects = CitationsProject.unlabeled( @assignment.project, params[:count] )
        @past_labels = Label.last_updated( current_user, @assignment.project, 0, params[:count] )
        render 'screen.json'
      end

      api :GET, '/v1/assignments/:id/history', 'List of citations that the user has most recently labeled and the  labels themselves'
      formats [:json]
      def history
        count = params[:count].to_i
        offset = params[:offset].to_i
        @past_labels = Label.last_updated( current_user, @assignment.project, offset, count )
        render 'history.json'
      end

    private
      def set_assignment
        @assignment = Assignment.find( params[:id] )
      end
    end
  end
end
