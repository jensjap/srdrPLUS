module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [:screen, :history]

      api :GET, '/v1/assignments/:id/screen', 'List of citations to screen'
      formats [:json]
      def screen
        @unlabeled_citations_projects = CitationsProject.unlabeled( @assignment.project, params[:count] )
        @past_labels = Label.last_updated( current_user, @assignment.project, params[:count] )
        render 'screen.json'
      end

      api :GET, '/v1/assignments/:id/history', 'List of citations that the user has most recently labeled and the  labels themselves'
      formats [:json]
      def history
        count = params[:count].to_i
        start = params[:start].to_i
        @past_labels = Label.last_updated( current_user, @assignment.project, count + start ).all[-count..-1]
        render 'history.json'
      end
      

    private
      def assignment_params
        params.require(:assignment).permit(:screen, :count)
      end

      def set_assignment
        @assignment = Assignment.find( params[:id] )
      end
    end
  end
end
