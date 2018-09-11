class Api::V1::CitationsController < Api::V1::BaseController
  def index
    @citations = Citation.all
  end
end

