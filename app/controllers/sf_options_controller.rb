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
          return render json: @sf_option if new_index < 0 || new_index >= @sf_options.length

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

  def existing_data_check
    @sf_option = SfOption.find(params[:id])
    respond_to do |format|
      format.json do
        has_sf_abstract_records = @sf_option.sf_cell.sf_abstract_records.any? do |sf_abstract_record|
          sf_abstract_record.value == @sf_option.name
        end
        has_sf_fulltext_records = @sf_option.sf_cell.sf_fulltext_records.any? do |sf_fulltext_record|
          sf_fulltext_record.value == @sf_option.name
        end
        render json: { has_records: has_sf_abstract_records || has_sf_fulltext_records }
      end
    end
  end

  def destroy
    @sf_option = SfOption.find(params[:id])
    respond_to do |format|
      format.json do
        if params[:deleteExistingAnswers]
          sf_cell = @sf_option.sf_cell
          sf_cell.sf_abstract_records.each do |sf_abstract_record|
            sf_abstract_record.destroy if sf_abstract_record.value == @sf_option.name
          end
          sf_cell.sf_fulltext_records.each do |sf_fulltext_record|
            sf_fulltext_record.destroy if sf_fulltext_record.value == @sf_option.name
          end
        else
          @sf_option.destroy
        end
        render json: {}
      end
    end
  end
end
