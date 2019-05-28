class TeamsController < ApplicationController
  before_action :set_project, only: [:create]
  before_action :set_team, only: [:update, :destroy]

  def create
  end

  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to project_citations_path(@team.project, anchor: 'panel-screening-teams'), notice: 'Success!' }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_team
      @team = Team.find(params[:id])
    end

    def team_params
      params.require(:team)
        .permit(:team_type_id, :name, :enabled,
               projects_users_roles_teams_attributes: [:id, :projects_users_role_id, :_destroy])
    end
end
