namespace :quality_dimension_tasks do
  desc "Add quality dimensions from quality_dimensions.yml to quality_dimension_sections table."
  task add_quality_dimensions: [:environment] do
    qd_yml = YAML.load_file('./lib/tasks/quality_dimensions.yml')
    qd_yml.each do |section|
      section_title       = section['section-title']
      section_description = section['section-description']
      if QualityDimensionQuestion.where(quality_dimension_section: QualityDimensionSection.find_by(name: section_title)).blank?
        qds = QualityDimensionSection.find_or_create_by(
          name: section_title,
          description: section_description
        )
        section['dimensions'].each do |d|
          qdq = QualityDimensionQuestion.create(
            quality_dimension_section: qds,
            name: d['question'],
            description: d['description']
          )
          d['options'].each do |opt|
            option = QualityDimensionOption.find_or_create_by(name: opt['option'])
            QualityDimensionQuestionsQualityDimensionOption.create(
              quality_dimension_question: qdq,
              quality_dimension_option: option
            )
          end
        end
      else
        puts "#{ section_title } already exists. Skipping.."
      end
    end
    # All your magic here
    # Any valid Ruby code is allowed
  end

  desc "Clear Quality Dimension Question table"
  task clear_quality_dimension_question_table: [:environment] do
    puts "Clearing Quality Dimension Question table"
    QualityDimensionQuestion.transaction do
      QualityDimensionQuestion.destroy_all
    end
    puts "Finished clearing Question table"
  end

  task :all => [:clear_quality_dimension_question_table, :add_quality_dimensions]
end
