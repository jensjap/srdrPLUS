class StatusingsController < ApplicationController
  before_action :set_statusing, only: [:update]

  # PATCH /extractions_extraction_forms_projects_sections/1/statusing.js
  def update
    respond_to do |format|
      format.js do
        @info = if !policy(@statusing.project).update?
                  [true, 'You are not authorized to make changes', 'red']
                elsif @statusing.update(statusing_params)
                  [true, 'Saved!', '#410093']
                else
                  [false, 'An error occured.  Changes have not been saved.', 'red']
                end
      end
    end
  end

  private

  def set_statusing
    @statusing = Statusing.find params[:id]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def statusing_params
    params.require(:statusing).permit(:status_id)
  end
end
