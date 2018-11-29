class OrganizationsController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.by_query(params[:q])
  end
end
