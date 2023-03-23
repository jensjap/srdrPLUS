class SectionsController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization, only: [:index]

  # GET /sections
  # GET /sections.json
  def index
    @sections = Section
                .includes(suggestion: { user: :profile })
                .by_query(params[:q])
  end
end
