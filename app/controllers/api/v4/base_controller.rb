class Api::V4::BaseController < ApplicationController
  respond_to :json

  def_param_group :paginate do
    param :page,     :number, desc: 'Page of paginated request.'
    param :per_page, :number, desc: 'Number of responses per page.'
  end

  def_param_group :resource_id do
    param :id, :number, desc: 'Resource ID.', required: true
  end

  private

  def authenticate_user!
    super unless current_user
  end

  def current_user
    return User.find_by(api_key:) if api_key.present?

    super
  end

  def api_key
    request.headers['api-key'] || request.params['api_key']
  end
end
