class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show]

  def index
    @organizations = Organization.where('name like ?', "%#{ params[:q] }%")
  end

  def show
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end
end
