module Api
  module V1
    class LabelsReasonsController < BaseController
    #  api :DESTROY, '/v1/note/:id', 'deletes specified note'
    #  def destroy
    #    @note = Note.find( params[ :id ] ).destroy
    #  end
      
      #api :CREATE, '/v1/note', 'creates a new note with specified tag and citations_project'
      def create
      end

      private
        def labels_reasons_params
          params.require( :labels_reasons )
                .permit( :id, :label_id, :reason_id )
        end
    end
  end
end
