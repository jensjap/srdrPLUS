module Api
  module V1
    class AssignmentsController < BaseController
      before_action :set_assignment, only: [:screen, :history]

      api :GET, '/v1/assignments/:id/screen', 'List of citations to screen'
      formats [:json]
      def screen
        @unlabeled_citations_projects = CitationsProject.
          unlabeled( @assignment.project, params[:count] ).
          includes( citation: [ :authors, :keywords, :journal ], 
                      taggings: [ :tag, projects_users_role: [ user: [ :profile ] ] ], 
                      notes: [ projects_users_role: [ user: [ :profile ] ] ] )
        @past_labels = Label.last_updated( @assignment.projects_users_role, 0, params[:count] ).
                    includes( 
                      labels_reasons: [ :reason ], 
                      citations_project: [ 
                        citation: [ :authors, :keywords, :journal ], 
                          taggings: [ :tag, projects_users_role: [ user: [ :profile ] ] ], 
                          notes: [ projects_users_role: [ user: [ :profile ] ] ] ] )

        render 'screen.json'
      end

      api :GET, '/v1/assignments/:id/history', 'List of citations that the user has most recently labeled and the  labels themselves'
      formats [:json]

      def history
        count = params[:count] || 100
        offset = params[:offset] || 0
        @past_labels = Label.last_updated( @assignment.projects_users_role, 0, params[:count] ).
                    includes( 
                      labels_reasons: [ :reason ],
                      citations_project: [ 
                        citation: [ :authors, :keywords, :journal ], 
                          taggings: [ :tag, projects_users_role: [ user: [ :profile ] ] ], 
                          notes: [ projects_users_role: [ user: [ :profile ] ] ] ] )
        render 'history.json'
      end

    private
      def set_assignment
        @assignment = Assignment.find( params[:id] )
      end
    end
  end
end
