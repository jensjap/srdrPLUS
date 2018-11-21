module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [:screen, :history]

      api :GET, '/v1/assignments/:id/screen', 'List of citations to screen'
      formats [:json]
      def screen
        @unlabeled_citations_projects = CitationsProject.
          unlabeled( @assignment.project, params[:count] ).
          includes( citation: [ :authors, :keywords, :journal ] )
        @unlabeled_taggings = Tagging.where( taggable_type: 'CitationsProject',
                        taggable_id: @unlabeled_citations_projects.map { |cp| cp.id }, 
                        projects_users_role: @assignment.
                                              projects_users_role.
                                              projects_user.
                                              projects_users_roles ).
                includes( :tag ).
                group_by { |tagging| tagging.taggable_id }

        @unlabeled_notes = Note.where( notable_type: 'CitationsProject',
                        notable: @unlabeled_citations_projects.map { |cp| cp.id }, 
                        projects_users_role: @assignment.
                                              projects_users_role.
                                              projects_user.
                                              projects_users_roles ).
                order( created_at: :asc ).
                group_by { |note| note.notable_id }

        @past_labels = Label.last_updated( @assignment.projects_users_role, 0, params[:count] ).
                      includes( 
                      labels_reasons: [ :reason ], 
                      citations_project: [ 
                        citation: [ :authors, :keywords, :journal ] ] )

        @labeled_taggings = Tagging.
          where(  taggable: @past_labels.map { |label| label.citations_project }, 
                        projects_users_role: @assignment.
                                              projects_users_role.
                                              projects_user.
                                              projects_users_roles ).
                includes( :tag ).
                group_by { |tagging| tagging.taggable_id }

        @labeled_notes = Note.
                where(  notable: @past_labels.map { |label| label.citations_project }, 
                        projects_users_role: @assignment.
                                              projects_users_role.
                                              projects_user.
                                              projects_users_roles ).
                order( created_at: :asc ).
                group_by { |note| note.notable_id }


        @assignment_options = @assignment.assignment_options.includes( :assignment_option_type, :label_type )

        render 'screen.json'
      end

      api :GET, '/v1/assignments/:id/history', 'List of citations that the user has most recently labeled and the  labels themselves'
      formats [:json]

      def history
        count = params[:count] || 100
        offset = params[:offset] || 0
        @past_labels = Label.last_updated( @assignment.projects_users_role, 0, params[:count] ).
              includes( labels_reasons: [ :reason ],
                        citations_project: [
                        citation: [ :authors, :keywords, :journal ] ] )

        @labeled_taggings = Tagging.where(
                        taggable: @past_labels.map { |label| label.citations_project },
                        projects_users_role: @assignment.
                                              projects_users_role.
                                              projects_user.
                                              projects_users_roles ).
                        includes( :tag ).
                        group_by { |tagging| tagging.taggable_id }

        @labeled_notes = Note.where(
                        notable: @past_labels.map { |label| label.citations_project },
                        projects_users_role: @assignment.
                                              projects_users_role.
                                              projects_user.
                                              projects_users_roles ).
                order( created_at: :asc ).
                group_by { |note| note.notable_id }
        render 'history.json'
      end

    private
      def set_assignment
        @assignment = Assignment.find( params[:id] )
      end
    end
  end
end
