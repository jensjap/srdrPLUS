module Api
  module V1
    class ColorsController < BaseController
      before_action :set_projects_users_term_groups_color, only: [:destroy, :update]

      api :GET, '/v1/colors', 'List of colors'
      formats [:json]
      def index
        @colors = Color.all
      end
    end
  end
end

