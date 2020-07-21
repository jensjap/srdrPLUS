class PublishingsController < ApplicationController
  SD_META_DATUM = 'sd_meta_datum'
  def create
    publishable_model = find_publishable_model
    return render body: nil, :status => :bad_request unless publishable_model

    errors = publishable_model.check_publishing_eligibility
    if errors.present?
      flash[:errors] = "Some required fields are missing. Please go to the SR 360 record to fill out all required fields: #{errors.join(', ')}"
    else
      flash[:success] = "Success! Your request is received. We will inform you once the SR 360 for this project is public."
    end

    redirect_back fallback_location: root_path
  end

  def destroy
    publishing = Publishing.find(params[:id])
    if publishing.user == current_user && publishing.destroy
      flash[:success] = "Success! Your publication request was cancelled."
      return redirect_to '/projects'
    else
      flash[:error] = "You are not authorized to cancel this request."
      return redirect_to '/projects'
    end
  end

  private
    def find_publishable_model
      publishable_type = params[:type]

      if publishable_type == SD_META_DATUM
        SdMetaDatum.find(params[:id])
      end
    end
end
