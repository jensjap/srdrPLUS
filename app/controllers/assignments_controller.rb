class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:screen]

  def screen
    @citations_projects = CitationsProject.unlabeled( @assignment.project ).limit(5)
    @label = Label.new
    render 'screen'
  end

  private
    def set_assignment
      @assignment = Assignment.find( params[:id] )
    end
end


