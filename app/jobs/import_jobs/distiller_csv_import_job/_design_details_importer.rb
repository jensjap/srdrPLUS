require '_shared_methods'

# we asume that the citations are imported before calling this

def import_design_details_from_distiller_csv project, design_details_file_path
  dd_csv = Roo::CSV design_details_file_path

  get_question_structure dd_csv.headers

  dd_csv.each_row do |row|

  end

end