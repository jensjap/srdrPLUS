module Api
  module V1
    class OrderingsController < BaseController
      def update_positions
        Ordering.transaction do
          orderings_params['orderings'].values.each_with_index do |o, index|
            ordering = Ordering.find(o['id'])
            ordering.update!(position: index + 1)
          end
        end

        respond_to do |format|
          format.json { head :ok }
        end
      end

      private
        def orderings_params
          params.permit(:drop_conflicting_dependencies, orderings: [:id, :position])
        end
    end
  end
end
