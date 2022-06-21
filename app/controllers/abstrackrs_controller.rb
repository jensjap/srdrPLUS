class AbstrackrsController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope
  skip_before_action :authenticate_user!
  before_action :set_abstrackr, only: %i[show edit update destroy]
  layout 'abstrackr'
  respond_to :html

  def index
    @abstrackrs = Abstrackr.all
    respond_with(@abstrackrs)
  end

  def show
    respond_with(@abstrackr)
  end

  def new
    @abstrackr = Abstrackr.new
    respond_with(@abstrackr)
  end

  def edit; end

  def create
    @abstrackr = Abstrackr.new(abstrackr_params)
    @abstrackr.save
    respond_with(@abstrackr)
  end

  def update
    @abstrackr.update(abstrackr_params)
    respond_with(@abstrackr)
  end

  def destroy
    @abstrackr.destroy
    respond_with(@abstrackr)
  end

  private

  def set_abstrackr
    @abstrackr = Abstrackr.find(params[:id])
  end

  def abstrackr_params
    params[:abstrackr]
  end
end
