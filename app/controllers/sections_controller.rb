class SectionsController < ApplicationController
  # GET /sections
  # GET /sections.json
  def index
    @sections = Section.includes(:suggestion).by_query(params[:q])
  end
end
