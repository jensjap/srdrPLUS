class PublicDataController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope, :set_record, only: [:show]
  skip_before_action :authenticate_user!

  def show
    render @template
    return render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found unless @project && @project.public?
  end

  private
    def set_record
      id = params[:id]

      case params[:type]
      when 'project'
        @project = Project.find(id)
        @template = '/public_data/project.html.slim'
      when 'extraction_form'
        @efp = ExtractionFormsProject.find(id)
        @project = @efp.project
        @template = '/public_data/extraction_form.html.slim'
      when 'extraction'
        # todo
      end
    end
end
