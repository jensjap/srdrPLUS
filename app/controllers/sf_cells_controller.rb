class SfCellsController < ApplicationController
  def create
    respond_to do |format|
      format.json do
        @sf_cell = SfCell.create(params.permit(:sf_row_id, :sf_column_id, :cell_type))
        render json: @sf_cell
      end
    end
  end

  def update
    @sf_cell = SfCell.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_cell.update(params.permit(:min, :max, :with_equality))
        render json: @sf_cell
      end
    end
  end

  def destroy
    @sf_cell = SfCell.find(params[:id])
    respond_to do |format|
      format.json do
        @sf_cell.destroy
        render json: {}
      end
    end
  end
end
