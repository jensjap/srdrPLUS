namespace :records_tasks do
  desc "Text, Numeric, Dropdown, Radio, and Select2_single all should have only 1 recordable."
  task find_single_record_qrcs: [:environment] do
  	# eefps_qrcfs = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
  	#   .select('count(*), group_concat(id)')
  	#   .group(
  	#   	'extractions_extraction_forms_projects_sections_type1_id',
  	#   	'extractions_extraction_forms_projects_section_id',
  	#   	'question_row_column_field_id')
  	#   .having('count(*) > 1')
  	eefps_qrcfs = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
  	  .group(
  	  	'extractions_extraction_forms_projects_sections_type1_id',
  	  	'extractions_extraction_forms_projects_section_id',
  	  	'question_row_column_field_id')
  	  .having('count(*) > 1')

  	eefps_qrcfs.each do |eefps_qrcf|
  	  recordables = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.where(
  	  	extractions_extraction_forms_projects_sections_type1_id: eefps_qrcf.extractions_extraction_forms_projects_sections_type1_id,
  	  	extractions_extraction_forms_projects_section_id: eefps_qrcf.extractions_extraction_forms_projects_section_id,
  	  	question_row_column_field_id: eefps_qrcf.question_row_column_field_id
  	  )

      section = eefps_qrcf.extractions_extraction_forms_projects_section.section
      if eefps_qrcf.project.id.eql?(973)
        case eefps_qrcf.question_row_column_field.question_row_column.question_row_column_type_id
        when 1, 2, 6, 7, 8
          extraction = eefps_qrcf.extraction
          qrc = eefps_qrcf.question_row_column_field.question_row_column
  	      records = Record.where(recordable: recordables).reorder(updated_at: :desc).to_a
  	      newest_record = records.shift
  	      puts "Extraction ID: #{ extraction.id }"
  	      puts "Section: #{ section.name }"
  	      puts "Arm: #{ eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1.name }"
          puts "#{ qrc.question.name }: [#{ qrc.question_row.name }] x [#{ qrc.name }]"
  	      puts "  Newest record: #{ newest_record.name }"
  	      puts "  Would delete the following:"
  	      p records.map(&:name).join(', ')
  	      records.each do |record|
  	      	record.recordable.destroy
  	      end
  	      puts "----------------"
  	    end
  	  end
  	end


  	# eefps_qrcfs.each do |eefps_qrcf|
   #    case eefps_qrcf.question_row_column_field.question_row_column.question_row_column_type_id
   #    when 1, 2, 6, 7, 8
   #    	qrc = eefps_qrcf.question_row_column_field.question_row_column

   #    	if eefps_qrcf.project.id.eql?(973)
   #    	  section = eefps_qrcf.extractions_extraction_forms_projects_section.section
   #    	  puts "#{ section.name }"
   #        puts "#{ qrc.question.name }: [#{ qrc.question_row.name }] x [#{ qrc.name }]"
   #        debugger
   #      end
   #    end
  	# end


  	# QuestionRowColumn.all.each do |qrc|
  	#   case qrc.question_row_column_type
  	#   when 1, 2, 6, 7, 8
  	#   	if
  	#   end
  	# end
  end

  task all: [:find_single_record_qrcs]
end