class OrganizationsController < ApplicationController
  before_action :set_organization, only: [:show]

  def index
    @organizations = Organization.where('name like ?', "%#{ params[:q] }%").order(:name)
    if @organizations.empty?
      @organizations = [ OpenStruct.new(id: "<<<#{ params[:q] }>>>", name: "New: '#{ params[:q] }'", suggestion: false) ]
    else
      @organizations
    end
  end

  def show
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end
end

