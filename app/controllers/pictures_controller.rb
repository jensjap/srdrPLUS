class PicturesController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization

  def delete_image_attachment
    @picture = ActiveStorage::Attachment.find(params[:id])
    authorize(@picture.record.project)
    @picture.purge
    render json: {}, status: 200
  end
end
