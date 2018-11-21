class LabelsController < ApplicationController
  before_action :set_label, only: [:show, :edit, :update, :destroy]
  before_action :skip_policy_scope

  def new
    skip_authorization
    skip_policy_scope
    @label = Label.new
  end

  def create
    Label.transaction do
      authorize(ProjectsUsersRole.find(label_params[ 'projects_users_role_id']).project, policy_class: LabelPolicy)
      @label = Label.create( citations_project_id: label_params[ 'citations_project_id' ], label_type_id: label_params[ 'label_type_id' ], projects_users_role_id: label_params[ 'projects_users_role_id'] )
      @label.update( label_params )
    end
    respond_to do |format|
      if @label.save
        format.html { redirect_to edit_label_path(@label), notice: t('success') }
        format.json { render json: label_hash( @label ) }
      else
        format.html { render 'new' }
        format.json { render json: @label.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @label.update( label_params )
        format.json { render json: label_hash( @label ) }
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

    def label_hash( label )
      hash = { id: label.id, labels_reasons: label.labels_reasons.map { |lr| { id: lr.id, reason: { id: lr.reason.id, name: lr.reason.name } } } }
    end

    def set_label
      @label = Label.find(params[:id])
      authorize(@label, policy_class: LabelPolicy)
    end

    def label_params
      params.require(:label)
            .permit(:name, :citations_project_id, :label_type_id, :projects_users_role_id, labels_reasons_attributes: [ :id, :label_id, :reason_id, :projects_users_role_id, :_destroy, reason_attributes: [ :id, :name ] ] )
    end
end
