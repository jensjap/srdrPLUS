module Api
  module V1
    class ProjectsUsersTermGroupsColorsTermsController < BaseController
      before_action :set_putgct, only: [:destroy]

      # api :DESTROY, '/v1/projects_users_term_groups_colors_terms/:id', 'Deletes specified projects_users_term_groups_colors_term'
      def destroy
        @putgct.destroy
        head :no_content
      end

      # api :POST, '/v1/projects_users_term_groups_colors_terms', 'Creates a new projects_users_term_groups_colors_term with specified projects_users_term_groups_color and term'
      def create
        #term = Term.where(id: putgct_params[:term_id]).first
        #if term.nil?
        #  term_name = putgct_params[:term_id].gsub!(/<<<(.+?)>>>/) { |term_name|
        #    term_name = $1
        #  }
        #  term = Term.find_or_create_by(name: term_name)
        #end
        term = Term.find_or_create_by(name: putgct_params[:term_name])
        putgc = ProjectsUsersTermGroupsColor.find(putgct_params['projects_users_term_groups_color_id'])
        @putgct = ProjectsUsersTermGroupsColorsTerm.create(projects_users_term_groups_color: putgc, term: term)
        render json: { id: @putgct.id }
      end

      # api :PATCH, '/v1/projects_users_term_groups_colors/:id', 'Updates specified projects_users_term_groups_color with a new term'
      def update
        term = Term.where(id: putgct_params[:term_id]).first
        if term.nil?
          term_name = putgct_params[:term_id].gsub!(/<<<(.+?)>>>/) { |term_name|
            term_name = $1
          }
          term = Term.find_or_create_by(name: term_name)
        end
        @putgct.update(term: term)
        render json: { id: @putgct.id }
      end

      private
        def set_putgct
          @putgct = ProjectsUsersTermGroupsColorsTerm.find(params[:id])
        end

        def putgct_params
          params.require(:projects_users_term_groups_colors_term)
                .permit(:projects_users_term_groups_color_id, :term_name)
                #.permit(:projects_users_term_groups_color_id, :term_id)
        end
    end
  end
end

