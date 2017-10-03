class TasksController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  
  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
    respond_to do |format|
      if @task.save
        format.html { redirect_to edit_task_path(@task), notice: t('success') }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else 
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: t('removed') }
      format.json { head :no_content }
    end
  end

  def index
  end

  def show
  end

  private
    def set_task
      @task = Task.includes(:task_type)
                  .includes(:assignments)
                  .find(params[:id])
    end

    def task_params
      params.require(:task)
          .permit(:name, :task_type_id, :num_assigned, :project_id, 
          assignments_attributes: [:id, :done_so_far, :date_assigned, :date_due, :done, 
                                   :user_id, :project_id])
    end
end
