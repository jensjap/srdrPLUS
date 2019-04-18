module Api
  module V1
    class NotesController < BaseController
      before_action :set_note, :skip_policy_scope, only: [ :update, :destroy ]

      api :DESTROY, '/v1/notes/:id', 'deletes specified note'
      def destroy
        authorize(@note.project, policy_class: NotePolicy)
        @note.destroy
        head :no_content
      end

      api :CREATE, '/v1/notes', 'creates a new note with specified tag and citations_project'
      def create
        @note = Note.create(note_params)
        authorize(@note.project, policy_class: NotePolicy)
        render json: { id: @note.id }
      end

      api :UPDATE, '/v1/notes/:id', 'updates a new note with specified tag and citations_project'
      def update
        @note.update( note_params )
        render json: { id: @note.id }
      end

      private
        def set_note
          @note = Note.find( params[:id] )
        end

        def note_params
          params.require( :note )
                  .permit( :value, :notable_id, :notable_type, :projects_users_role_id )
        end
    end
  end
end
