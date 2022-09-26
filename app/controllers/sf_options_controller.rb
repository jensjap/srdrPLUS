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
        if (new_index = params[:new_index])
          @sf_options = @sf_option.sf_cell.sf_options.order(:position).to_a
          return render json: @sf_option if (new_index < 0 || new_index >= @sf_options.length)
          @sf_options.insert(new_index, @sf_options.delete_at(@sf_options.index(@sf_option)))
          @sf_options.each_with_index do |sf_option, index|
            sf_option.update(position: index)
          end
        else
          @sf_option.update(params.permit(:with_followup))
        end
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
