# Attempt to find the column index in the given row for a cell that starts with given value.
#
# returns (Boolean, Idx)
def _find_column_idx_with_value(row, value)
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

# We keep several dictionaries here. They all track the same information such as type1s, populations and timepoints.
# One list is kept as a master list. Those are on SheetInfo.type1s, SheetInfo.populations, and SheetInfo.timepoints.
# Another is kept for each extraction.
class SheetInfo
  attr_reader :header_info, :extractions, :key_question_selections, :type1s, :populations, :timepoints, :question_row_columns, :rssms

  def initialize
    @header_info             = ['Extraction ID', 'Consolidated', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID', 'Authors', 'Publication Date', 'Key Questions']
    @key_question_selections = Array.new
    @extractions             = Hash.new
    @type1s                  = Set.new
    @populations             = Set.new
    @timepoints              = Set.new
    @question_row_columns    = Set.new
    @rssms                   = Set.new
  end

  def new_extraction_info(extraction)
    @extractions[extraction.id] = {
      extraction_id: extraction.id,
      type1s:               [],
      populations:          [],
      timepoints:           [],
      question_row_columns: [],
      rssms:                [] }
  end

  def set_extraction_info(params)
    @extractions[params[:extraction_id]][:extraction_info] = params
  end

  def add_type1(params)
    @extractions[params[:extraction_id]][:type1s] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    @type1s << dup
  end

  def add_population(params)
    @extractions[params[:extraction_id]][:populations] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    @populations << dup
  end

  def add_timepoint(params)
    @extractions[params[:extraction_id]][:timepoints] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    @timepoints << dup
  end

  def add_question_row_column(params)
    @extractions[params[:extraction_id]][:question_row_columns] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    dup.delete(:eefps_qrfc_values)
    @question_row_columns << dup
  end

  def add_rssm(params)
    @extractions[params[:extraction_id]][:rssms] << params
    dup = params.deep_dup
    dup.delete(:extraction_id)
    dup.delete(:rssm_values)
    @rssms << dup
  end
end
