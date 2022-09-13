class SfQuestionsController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        render json: {}
      end
    end
  end
end
