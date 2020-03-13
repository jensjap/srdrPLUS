namespace :result_statistic_section_tasks do
  desc "Use ./lib/tasks/result_statistic_section_seed_measures.yml to populate
  result_statistic_section_types_measures table. This table contains information
  about which measures should be presented as options for each result statistic
  section by outcome type."
  task populate_seed_measures_table: [:environment] do
    TYPE1_TYPES_TO_ID = {
      "Categorical"   => Type1Type.find_by(name: "Categorical").id,
      "Continuous"    => Type1Type.find_by(name: "Continuous").id,
      "Time to Event" => Type1Type.find_by(name: "Time to Event").id,
      "Adverse Event" => Type1Type.find_by(name: "Adverse Event").id
    }

    RSS_TYPES_TO_ID = {
      "Descriptive Statistics"  => ResultStatisticSectionType.find_by(name: "Descriptive Statistics").id,
      "Between Arm Comparisons" => ResultStatisticSectionType.find_by(name: "Between Arm Comparisons").id,
      "Within Arm Comparisons"  => ResultStatisticSectionType.find_by(name: "Within Arm Comparisons").id,
      "NET Change"              => ResultStatisticSectionType.find_by(name: "NET Change").id
    }

    def get_lsof_type1_type_ids(measure)
      return measure["type1_types"].map { |t1t_type| TYPE1_TYPES_TO_ID[t1t_type] }
    end

    def get_lsof_rss_type_ids(measure)
      return measure["result_statistic_section_types"].map { |rss_type| RSS_TYPES_TO_ID[rss_type] }
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

    def find_provider_rsstm(rsst_id, provider_m, default=true, t1t_id)
      return ResultStatisticSectionTypesMeasure.find_by(
        result_statistic_section_type_id: rsst_id,
        measure: provider_m,
        default: true,
        type1_type_id: t1t_id,
        result_statistic_section_types_measure_id: nil
      )
    end

    rss_seed_measures_yml = YAML.load_file('./lib/tasks/result_statistic_section_seed_measures.yml')
    rss_seed_measures_yml.each do |measure|
      m = Measure.find_or_create_by(name: measure["name"])
      provider_m = Measure.find_by(name: measure["provider_name"])
      get_lsof_rss_type_ids(measure).each do |rsst_id|
        # If the measure belongs to a specific outcome type we set default to true
        # and create a record for each of the outcome types.
        if measure["type1_types"].present?
          get_lsof_type1_type_ids(measure).each do |t1t_id|
            provider = find_provider_rsstm(rsst_id, provider_m, true, t1t_id)
            find_or_create_rsstm(rsst_id, m, true, t1t_id, provider)
          end

        # Otherwise create a record for all type1_types but set default to false.
        else
          TYPE1_TYPES_TO_ID.values.each do |t1t_id|
            provider = find_provider_rsstm(rsst_id, provider_m, true, t1t_id)
            find_or_create_rsstm(rsst_id, m, false, t1t_id, provider)
          end
        end
      end
    end
  end

  desc "Clear all seed measures for the result statistic sections"
  task clear_seed_measures: [:environment] do
    puts "Clearing Seed Measures"
    ResultStatisticSectionTypesMeasure.transaction do
      ResultStatisticSectionTypesMeasure.destroy_all
    end
    puts "Done Clearing Seed Measures"
  end

  task :all => [:clear_seed_measures, :populate_seed_measures_table]
end
