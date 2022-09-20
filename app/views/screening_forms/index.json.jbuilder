json.screening_form_id @screening_form.id
json.sf_questions @screening_form.sf_questions.order(:position) do |sf_question|
  cell_hash = {}
  sf_question.sf_rows.each do |sf_row|
    sf_row.sf_cells.each do |sf_cell|
      if cell_hash[sf_cell.sf_row_id].nil?
        cell_hash[sf_cell.sf_row_id] = { sf_cell.sf_column_id => sf_cell }
      else
        cell_hash[sf_cell.sf_row_id][sf_cell.sf_column_id] = sf_cell
      end
    end
  end

  json.id sf_question.id
  json.name sf_question.name
  json.description sf_question.description

  json.rows sf_question.sf_rows do |sf_row|
    json.id sf_row.id
    json.title sf_row.name
  end
  json.columns sf_question.sf_columns do |sf_column|
    json.id sf_column.id
    json.title sf_column.name
  end

  json.cells sf_question.sf_rows do |sf_row|
    json.array!(sf_question.sf_columns) do |sf_column|
      cell = cell_hash[sf_row.id] && cell_hash[sf_row.id][sf_column.id]
      if cell
        json.id cell.id
        json.sf_row_id cell.sf_row_id
        json.sf_column_id cell.sf_column_id
        json.cell_type cell.cell_type
        json.min cell.min
        json.max cell.max
        json.with_equality cell.with_equality
        json.options cell.sf_options do |sf_option|
          json.id sf_option.id
          json.name sf_option.name
          json.with_followup sf_option.with_followup
        end
      else
        json.nil!
      end
    end
  end
end
