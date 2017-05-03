class OrganizationsController < ApplicationController
  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.by_query(params[:q])
  end
end

