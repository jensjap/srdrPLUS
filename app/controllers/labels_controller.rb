class LabelsController < ApplicationController
  before_action :set_label, only: [:show, :edit, :update, :destroy]

  def new
    @label = Label.new
  end

  def create
    @label = Label.new( label_params )
    @label.user = current_user
    respond_to do |format|
      if @label.save
        format.html { redirect_to edit_label_path(@label), notice: t('success') }
        format.json { render json: { id: @label.id, status: :created } }
      else
        format.html { render 'new' }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @label.update( label_params )
        format.json { render json: { id: @label.id, status: :updated } }
      else
        format.json { render json: @label.errors, status: :unprocessable_entity }
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
