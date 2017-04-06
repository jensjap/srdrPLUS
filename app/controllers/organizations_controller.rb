class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.by_query(params[:q])
  end
end

