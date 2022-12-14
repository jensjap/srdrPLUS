class Cleanup
  def self.dedupe_extraction_forms_projects_section_options(destroy = false)
    number_of_destroyed = 0
    skipped = 0
    grouped = ExtractionFormsProjectsSectionOption
              .all
              .group_by do |model|
      [
        model.extraction_forms_projects_section_id
      ]
    end
    pre_grouped_size = grouped.size
    grouped.each_value do |duplicates|
      duplicates.sort_by!(&:id)
      duplicates.shift
      duplicates.each.each do |duplicate|
        duplicate.destroy if destroy
        number_of_destroyed += 1
      end
    end
    grouped = ExtractionFormsProjectsSectionOption
              .all
              .group_by do |model|
      [
        model.extraction_forms_projects_section_id
      ]
    end
    post_grouped_size = grouped.size
    raise unless pre_grouped_size.eql?(post_grouped_size)

    puts "able to destroy: #{number_of_destroyed}"
  end

  def self.destroy_orphan_extraction_forms_projects_section_options(destroy = false)
    number_of_destroyed = 0
    ExtractionFormsProjectsSectionOption.left_joins(:extraction_forms_projects_section).where(extraction_forms_projects_sections: { id: nil }).each do |efpso|
      efpso.destroy if destroy
      number_of_destroyed += 1
    end
    puts "able to destroy: #{number_of_destroyed}"
  end
end
