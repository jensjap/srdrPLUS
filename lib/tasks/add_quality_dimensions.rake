namespace :quality_dimension_tasks do
  desc "Add quality dimensions from quality_dimensions.yml to quality_dimension_sections table."
  task add_quality_dimensions: [:environment] do
    qd_yml = YAML.load_file('./lib/tasks/quality_dimensions.yml')
    qd_yml.each do |section_group|
      section_group_title       = section_group['section-group-title']
      qdsg = QualityDimensionSectionGroup.find_or_create_by(
          name: section_group_title
      )

      section_group['sections'].each do |section|
        section_title       = section['section-title']
        section_description = section['section-description']

        qdq_id_dict = {}

        if QualityDimensionQuestion.where(quality_dimension_section: QualityDimensionSection.find_by(name: section_title)).blank?
          qds = QualityDimensionSection.find_or_create_by(
              name: section_title,
              description: section_description,
              quality_dimension_section_group: qdsg
          )
          section['dimensions'].each do |d|
            qdq = QualityDimensionQuestion.create(
                quality_dimension_section: qds,
                name: d['question'],
                description: d['description']
            )

            qdq_id_dict[d['id']] = qdq

            d['options']&.each do |opt|
              option = QualityDimensionOption.find_or_create_by(name: opt['option'])
              QualityDimensionQuestionsQualityDimensionOption.create(
                  quality_dimension_question: qdq,
                  quality_dimension_option: option
              )
            end
          end
          section['dimensions'].each do |d|
            depen = qdq_id_dict[d['id']]
            d['dependencies']&.each do |prereq|
              prereq_q = qdq_id_dict[prereq['id']]
              prereq['options']&.each do |o|
                prereq_o = prereq_q.quality_dimension_options.where(name: o['option']).first
                Dependency.find_or_create_by dependable_type: 'QualityDimensionQuestion',
                                             dependable_id: depen.id,
                                             prerequisitable_type: 'QualityDimensionOption',
                                             prerequisitable_id: prereq_o.id
              end
            end
          end
        else
          puts "#{ section_title } already exists. Skipping.."
        end
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
