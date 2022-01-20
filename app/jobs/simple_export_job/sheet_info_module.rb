module SheetInfoModule
  # Attempt to find the column index in the given row for a cell that starts with given value.
  #
  # returns (Boolean, Idx)
  def find_column_idx_with_value(row, value)
    row.cells.each do |cell|
      return [true, cell.index] if cell.value.end_with?(value)
    end

    return [false, row.cells.length]
  end

  # If no KQ's array is passed in, we export based on extraction.extractions_key_questions_projects_selections.
  # Note - jjap - 10-27-2020: This is counter to the design decision to let each question pick its
  #   own set of key questions. Doing it this way is akin to picking key questions based on the
  #   EFP...which means we should be able to create multiple EFPs just like in SRDR.
  def fetch_kq_selection(extraction, kq_ids)
    if kq_ids.blank?
      kq_ids = extraction
        .extractions_key_questions_projects_selections
        .order(key_questions_project_id: :asc)
        .collect(&:key_questions_project)
        .collect(&:key_question_id)
    end

    return kq_ids
  end
end