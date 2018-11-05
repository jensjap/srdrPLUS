class TasksController < ApplicationController
  before_action :set_project, only: [:index]
#  before_action :set_task, only: [:show, :edit, :update, :destroy]

#  def new
#      @task = Task.new
#      @task.authors.new
#      @task.build_journal
#      @task.keywords.new
#  end
#
#  def create
#    @task = Task.new(task_params)
#    respond_to do |format|
#      if @task.save
#        format.html { redirect_to edit_task_path(@task), notice: t('success') }
#        format.json { render :show, status: :created, location: @task }
#      else
#        format.html { render :new }
#        format.json { render json: @task.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  def update
#    respond_to do |format|
#      if @task.update(task_params)
#        format.html { redirect_to edit_task_path(@task), notice: 'Task was successfully updated.' }
#        format.json { render :show, status: :ok, location: @task }
#      else
#        format.html { render :edit }
#        format.json { render json: @task.errors, status: :unprocessable_entity }
#      end
#    end
#  end
#
#  def edit
#  end
#
#  def destroy
#    @task.destroy
#    respond_to do |format|
#      format.html { redirect_to tasks_url, notice: t('removed') }
#      format.json { head :no_content }
#     end
#  end
#
#  def show
#    render 'show'
#  end

  def index
    @tasks = Task.joins(:projects)
                         .group('tasks.id')
                         .where(:projects => { :id => @project.id }).all
    #@labels = Label.where(:user_id => current_user.id).where(:tasks_project_id => [@project.tasks_projects]).all
  end

#  def labeled
#    @tasks = Task.labeled(@project)
#    render 'index'
#  end
#
#  def unlabeled
#    @tasks = task.unlabeled(@project)
#    render 'index'
#  end

  private

    #a helper method that sets the current task from id to be used with callbacks
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_task
      @task = Task.includes(:journal)
                          .find(params[:id])
    end

#    def task_params
#      params.require(:task)
#          .permit(:name, :task_type_id, :pmid, :refman, :abstract,
#            journal_attributes: [:id, :name, :publication_date, :issue, :volume, :_destroy],
#            authors_attributes: [:id, :name, :_destroy] ,
#            keywords_attributes: [:id, :name, :_destroy],
#            labels_attributes: [:id, :value, :_destroy])
#    end
end
