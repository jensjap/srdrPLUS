module Api
  module V1
    class NotesController < BaseController
      api :DESTROY, '/v1/note/:id', 'deletes specified note'
      def destroy
        @note = Note.find( params[ :id ] ).destroy
      end
      
      api :CREATE, '/v1/note', 'creates a new note with specified tag and citations_project'
      def create
        @note = Note.create( note_params )
      end
      private
        def note_params
          params.require( :note )
                .permit( :value, :notable_id, :notable_type, :projects_users_role_id )
        end
    end
  end
end



