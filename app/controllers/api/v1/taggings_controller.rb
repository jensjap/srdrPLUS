module Api
  module V1
    class TaggingsController < BaseController
      api :DESTROY, '/v1/taggings/:id', 'deletes specified tagging'
      def destroy
        @tagging = Tagging.find( params[ :id ] ).destroy
        head :no_content
      end
      
      api :CREATE, '/v1/taggings', 'creates a new tagging with specified tag and citations_project'
      def create
        @tagging = Tagging.create( tagging_params )
        render json: { id: @tagging.id }
      end

      private
        def tagging_params
          params.require( :tagging )
                .permit( :tag_id, :taggable_id, :taggable_type, :projects_users_role_id, tag_attributes: [ :name ] )
        end
    end
  end
end


