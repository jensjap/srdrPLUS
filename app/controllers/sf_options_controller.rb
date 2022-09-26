class SfOptionsController < ApplicationController
  def create
    @sf_cell = SfCell.find(params[:sf_cell_id])
    respond_to do |format|
      format.json do
        if SfOption.find_by(name: params[:name], sf_cell: @sf_cell).present?
          render json: 'duplicate option', status: 400
        else
          @sf_cell.sf_options.create(name: params[:name])
          render json: @sf_cell
        end
      end
    end
  end

  def update
    @sf_option = SfOption.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_option.update(params.permit(:with_followup))
        render json: @sf_option
      end
    end
  end

  def destroy
    @sf_option = SfOption.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_option.destroy
        render json: {}
      end
    end
  end
end
