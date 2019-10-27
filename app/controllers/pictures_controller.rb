class PicturesController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization

  def delete_image_attachment
    @picture = ActiveStorage::Attachment.find(params[:id])
    @picture.purge
    head :no_content
  end
end
