class MessageUnreadsController < ApplicationController
  def destroy
    respond_to do |format|
      format.json do
        MessageUnread.find_by(id: params[:id])&.destroy
        render json: {}, status: 200
      end
    end
  end
end
