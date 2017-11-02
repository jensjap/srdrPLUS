class LabelsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_label, only: [:show, :edit, :update, :destroy]

  def new
    @label = Label.new
  end

  def create
    @label = Label.new(label_params)
    respond_to do |format|
      if @label.save
        format.json { render :show, status: :created, location: @label }
      else
        format.json { render json: @label.errors, status: :unprocessable_entity }
    end
  end

  def update
    respond_to do |format|
      if @label.update(label_params)
        format.json { render :show, status: :ok, location: @label }
      else
        format.json {render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @label.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def show
  end

  private
  def set_label
    @label = Label.find(params[:id])
  end

  def label_params
    params.require(:label)
          .permit(:name, :citations_project_id, :value, :user_id)
  end
end
