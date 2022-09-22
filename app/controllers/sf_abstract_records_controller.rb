class SfAbstractRecordsController < ApplicationController
  def index
    @abstract_screening_result = AbstractScreeningResult.find(params[:abstract_screening_result_id])
    @screening_form = ScreeningForm.find_by(project: @abstract_screening_result.project, form_type: 'abstract')

    respond_to do |format|
      format.json do
        @screening_form = ScreeningForm.includes(
          sf_questions: [
            {
              sf_rows: { sf_cells: %i[sf_options sf_abstract_records sf_fulltext_records] },
              sf_columns: { sf_cells: %i[sf_options sf_abstract_records sf_fulltext_records] }
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
        when 'text', 'numeric'
          @sf_abstract_record = SfAbstractRecord.find_or_create_by(sf_cell: @sf_cell,
                                                                   abstract_screening_result_id: params[:abstract_screening_result_id])
          @sf_abstract_record.update(params.permit(:value, :equality))
          render json: @sf_abstract_record
        end
      end
    end
  end
end
