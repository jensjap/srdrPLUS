sf_cells_hash = Hash.new { |h, k| h[k] = [] }
@abstract_screening_result.sf_abstract_records.each do |record|
  sf_cells_hash[record.sf_cell_id] << record
end
json.screening_form do
  json.id @screening_form.id
  json.form_type @screening_form.form_type
end
json.sf_questions @screening_form.sf_questions do |sf_question|
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
        sf_abstract_records_hash = {}
        cell.sf_abstract_records.where(abstract_screening_result: @abstract_screening_result).each do |sf_abstract_record|
          sf_abstract_records_hash[sf_abstract_record.value] =
            { sf_abstract_record_id: sf_abstract_record.id, followup: sf_abstract_record.followup }
        end
        json.id cell.id
        json.sf_row_id cell.sf_row_id
        json.sf_column_id cell.sf_column_id
        json.cell_type cell.cell_type
        json.min cell.min
        json.max cell.max
        json.with_equality cell.with_equality
        options = cell.sf_options.map do |sf_option|
          { id: sf_option.id,
            name: sf_option.name,
            with_followup: sf_option.with_followup,
            sf_abstract_record_id: sf_abstract_records_hash.dig(sf_option.name, :sf_abstract_record_id),
            followup: sf_abstract_records_hash.dig(sf_option.name, :followup) }
        end
        sf_cells_hash[cell.id].each do |sf_abstract_record|
          next if options.any? do |option|
                    option[:name] == sf_abstract_record[:value]
                  end || sf_abstract_record[:value].blank?

          options << { id: sf_abstract_record[:id], name: sf_abstract_record[:value] }
        end
        json.options options
        json.sf_records sf_cells_hash[cell.id]
        json.radio_selected sf_cells_hash[cell.id][0].try(&:value) if cell.cell_type == 'radio'
      else
        json.nil!
      end
    end
  end
end
