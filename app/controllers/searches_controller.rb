class SearchesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create]
  skip_before_action :verify_authenticity_token, only: [:create]
#  before_action :set_search, only: [:show, :edit, :update, :destroy]

  # GET /searches/new
  def new
    @results = params[:results].to_json if params[:results].present?
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = search_params
    @result = @search.to_s
    redirect_to new_search_path + '?results=' + @result
  end

  private
#    # Use callbacks to share common setup or constraints between actions.
#    def set_search
#    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params
        .require(:searches)
        .permit(projects_search:
                [:name,
                 :description,
                 :attribution,
                 :methodology_description,
                 :prospero,
                 :doi,
                 :notes,
                 :funding_source],
                citations_search:
                [:name,
                 :refman,
                 :pmid,
                 :abstract])
    end
end
