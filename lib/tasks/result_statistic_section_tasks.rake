namespace :result_statistic_section_tasks do
  desc "Use ./lib/tasks/result_statistic_section_seed_measures.yml to populate
  result_statistic_section_types_measures table. This table contains information
  about which measures should be presented as options for each result statistic
  section by outcome type."
  task populate_seed_measures_table: [:environment] do
    TYPE1_TYPES_TO_ID = {
      'categorical' => Type1Type.find_by(name: 'Categorical').id,
      'continuous' => Type1Type.find_by(name: 'Continuous').id
    }.freeze

    RSS_TYPES_TO_ID = {
      'Descriptive Statistics' => ResultStatisticSectionType.find_or_create_by(name: 'Descriptive Statistics').id,
      'Between Arm Comparisons' => ResultStatisticSectionType.find_or_create_by(name: 'Between Arm Comparisons').id,
      'Within Arm Comparisons' => ResultStatisticSectionType.find_or_create_by(name: 'Within Arm Comparisons').id,
      'Net Difference' => ResultStatisticSectionType.find_or_create_by(name: 'NET Change').id,
      'Diagnostic Test Descriptive Statistics' => ResultStatisticSectionType.find_or_create_by(name: 'Diagnostic Test Descriptive Statistics').id,
      'Diagnostic Test -placeholder for AUC and Q*-' => ResultStatisticSectionType.find_or_create_by(name: 'Diagnostic Test -placeholder for AUC and Q*-').id,
      'Diagnostic Test 2x2 Table' => ResultStatisticSectionType.find_or_create_by(name: 'Diagnostic Test 2x2 Table').id,
      'Diagnostic Test Test Accuracy Metrics' => ResultStatisticSectionType.find_or_create_by(name: 'Diagnostic Test Test Accuracy Metrics').id
    }.freeze

    def get_lsof_rss_type_ids(measure)
      measure['result_statistic_section_types'].map { |rss_type| RSS_TYPES_TO_ID[rss_type] }
    end

    def get_lsof_type1_type_ids(measure)
      measure['type1_types'].map { |t1t_type| TYPE1_TYPES_TO_ID[t1t_type] }
    end

    def find_or_create_rsstm(rsst_id, m, default, t1t_id, provider)
      ResultStatisticSectionTypesMeasure.find_or_create_by!(
        result_statistic_section_type_id: rsst_id,
        measure: m,
        default: default,
        type1_type_id: t1t_id,
        result_statistic_section_types_measure_id: provider.try(:id)
      )
    end

    def find_provider_rsstm(rsst_id, provider_m, t1t_id)
      ResultStatisticSectionTypesMeasure.find_by(
        result_statistic_section_type_id: rsst_id,
        measure: provider_m,
        type1_type_id: t1t_id
      )
    end

    def create_rsstm(rsst_id, measure, incl_by_default, t1t_id, provider_m)
      provider = provider_m.present? ? find_provider_rsstm(rsst_id, provider_m, t1t_id) : nil
      find_or_create_rsstm(rsst_id, measure, incl_by_default, t1t_id, provider)
    end

    rss_seed_measures_yml = YAML.load_file('./lib/tasks/result_statistic_section_seed_measures.yml')
    rss_seed_measures_yml.each do |measure|
      m = nil
      provider_ms = nil

      m = Measure.find_or_create_by(name: measure['name'])
      provider_m = Measure.find_by(name: measure['provider_names'])

      get_lsof_rss_type_ids(measure).each do |rsst_id|
        measure['type1_types'].each do |outcome_type, visibility|
          t1t_id = TYPE1_TYPES_TO_ID[outcome_type]

          case visibility
          when 'default'
            create_rsstm(rsst_id, m, true, t1t_id, provider_m)

          when 'available'
            create_rsstm(rsst_id, m, false, t1t_id, provider_m)

          when 'false'
            next
          end
        end
      end
    end

    puts 'Done Populating Seed Measures'
  end

  desc 'Clear all seed measures for the result statistic sections'
  task clear_seed_measures: [:environment] do
    puts 'Clearing Seed Measures'
    ActiveRecord::Base.connection.disable_referential_integrity do
      ResultStatisticSectionTypesMeasure.transaction do
        ResultStatisticSectionTypesMeasure.destroy_all
      end
    end
    puts "Done Clearing Seed Measures"
  end

  task :all => [:clear_seed_measures, :populate_seed_measures_table]
end
