class Api::V1::BaseController < ApplicationController
  respond_to :json

  private
    def authenticate_user!
      super unless current_user
    end

    def current_user
      return User.find_by(api_key: api_key) if api_key.present?
      super
    end

    def api_key
      request.headers['api-key'] || request.params['api_key']
    end
end
