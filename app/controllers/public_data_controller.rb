class PublicDataController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope, :set_record, only: [:show]
  skip_before_action :authenticate_user!

  def show
    render @template
  end

  private
    def set_record
      id = params[:id]

      case params[:type]
      when 'project'
        record = Project.find(id)
        @project = record
        @template = '/projects/show.html.slim'
      end

      return render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found unless record && record.public?
    end
end
