class EefpsHealthService
  def self.perform_check
    correct = 0
    incorrect = 0
    insufficient = 0
    extraneous = 0
    extraction_ids = []
    Project.all.each do |project|
      efp = project.extraction_forms_projects.first
      efps = efp.extraction_forms_projects_sections
      efps_ids = efps.map(&:id).sort

      project.extractions.each do |extraction|
        extractions_efps_ids = extraction.extraction_forms_projects_sections.map(&:id).sort
        if efps_ids == extractions_efps_ids
          correct += 1
        else
          incorrect += 1
          extraction_ids << extraction.id
          if (extractions_efps_ids - efps_ids).empty?
            insufficient += 1
          else
            extraneous += 1
          end
        end
      end
    end
    puts "correct: #{correct}"
    puts "incorrect: #{incorrect}"
    puts "extraneous: #{extraneous}"
    puts "insufficient: #{insufficient}"
  end

  def self.check_extraction_diff(extraction_id)
    efps_ids = Extraction.find(extraction_id).project.extraction_forms_projects.first.extraction_forms_projects_sections.map(&:id).sort
    e_efps_ids = Extraction.find(extraction_id).extraction_forms_projects_sections.map(&:id).sort
    p [efps_ids, e_efps_ids]
  end
end
