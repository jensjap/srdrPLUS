class SfFulltextRecordsController < ApplicationController
  def index
    @fulltext_screening_result = FulltextScreeningResult.find(params[:fulltext_screening_result_id])
    @screening_form = ScreeningForm.find_or_create_by!(project: @fulltext_screening_result.project,
                                                       form_type: 'fulltext')

    respond_to do |format|
      format.json do
        @screening_form = ScreeningForm.includes(
          sf_questions: [
            {
              sf_rows: { sf_cells: %i[sf_options sf_fulltext_records] },
              sf_columns: { sf_cells: %i[sf_options sf_fulltext_records] }
            }
          ]
        ).where(id: @screening_form.id).first
      end
      format.html
    end
  end

  def create
    @sf_cell = SfCell.find(params[:sf_cell_id])

    respond_to do |format|
      format.json do
        case @sf_cell.cell_type
        when 'text', 'numeric', 'dropdown'
          @sf_fulltext_record = SfFulltextRecord.find_or_create_by(
            sf_cell: @sf_cell,
            fulltext_screening_result_id: params[:fulltext_screening_result_id]
          )
          @sf_fulltext_record.update(params.permit(:value, :equality))
        when 'checkbox'
          @sf_fulltext_record = SfFulltextRecord.find_or_create_by(
            sf_cell: @sf_cell,
            fulltext_screening_result_id: params[:fulltext_screening_result_id],
            value: params[:value]
          )
          @sf_fulltext_record.update(followup: params[:followup]) if params[:followup]
        when 'radio'
          @sf_fulltext_record = SfFulltextRecord.find_or_create_by(
            sf_cell: @sf_cell,
            fulltext_screening_result_id: params[:fulltext_screening_result_id]
          )
          @sf_fulltext_record.update(params.permit(:value, :followup))
        when 'select-one'
          @sf_fulltext_record = SfFulltextRecord.find_or_create_by(
            sf_cell: @sf_cell,
            fulltext_screening_result_id: params[:fulltext_screening_result_id]
          )
          @sf_fulltext_record.update(params.permit(:value))
        when 'select-multiple'
          @sf_fulltext_record = SfFulltextRecord.find_or_create_by(
            sf_cell: @sf_cell,
            fulltext_screening_result_id: params[:fulltext_screening_result_id],
            value: params[:value]
          )
        else
          return render json: 'unrecognized cell_type', status: 400
        end
        render json: @sf_fulltext_record
      end
    end
  end

  def destroy
    @sf_cell = SfCell.find(params[:sf_cell_id])
    @sf_fulltext_record = SfFulltextRecord.find_by(
      sf_cell: @sf_cell,
      fulltext_screening_result_id: params[:fulltext_screening_result_id],
      value: params[:value]
    )

    respond_to do |format|
      format.json do
        case @sf_cell.cell_type
        when 'checkbox', 'select-one', 'select-multiple'
          @sf_fulltext_record.destroy
        end
        render json: @sf_fulltext_record
      end
    end
  end
end
