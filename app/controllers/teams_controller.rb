class TeamsController < ApplicationController
  before_action :set_project, only: [:create]
  before_action :set_team, only: [:update, :destroy]

  def create
    @team = @project.teams.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to project_citations_path(@project, anchor: 'panel-screening-teams'), notice: t('success') }
        format.json { render :show, status: :created, location: @citation }
      else
        format.html { render :new }
        format.json { render json: @citation.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to project_citations_path(@team.project, anchor: 'panel-screening-teams'), notice: 'Success!' }
        format.js
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.js
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
        .permit(:team_type_id, :project_id, :name, :enabled,
                invitations_attributes: [:id, :enabled, :_destroy],
                projects_users_roles_teams_attributes: [:id, :projects_users_role_id, :_destroy])
    end
end
