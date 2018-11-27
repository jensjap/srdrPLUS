module Api
  module V1
    class OrderingsController < BaseController
      def update_positions
        ordering_ids = []
        orderings_params['orderings'].values.each do |o|
          ordering = Ordering.find(o['id'])
          ordering.update(position: o['position'])
          ordering_ids << o['id']
        end
        respond_to do |format|
          format.json { head :ok }
        end
      end

      private
        def orderings_params
          params.permit(orderings:[:id, :position])
        end
    end
  end
end
