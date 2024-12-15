# Gweneth's project
PROJECT_ID = 6212  # Trichomonas Screening

module ScreeningUtilities
  class << self
    def advance_eligible_citations_to_full_text(project_id, dry_run: false)
      # Hash mapping eligibility status (true/false) to arrays of citations_project IDs
      # @type [Hash<Boolean, Array<Integer>>]
      eligibility_map = {
        true: [],
        false: []
      }
      project = Project.find(project_id)

      puts "Number of abstract screenings: #{project.abstract_screenings.count}"
      project.abstract_screenings.each do |screening|
        puts "  Abstract screening id: #{screening.id}"
        puts "  Abstract screening type: #{screening.abstract_screening_type}"
      end

      # CitationsProject records with 'asps' status.
      asps_cps = get_asps_citations_for_project(project)

      asps_cps.each do |cp|
        eligibility = check_eligibility_of_cp(cp)
        eligibility_map[eligibility].push(cp.id)
      end

      puts "\nDRY RUN SUMMARY:" if dry_run
      eligibility_map[:true].each do |eligible_cp_id|
        cp = CitationsProject.find(eligible_cp_id)
        if dry_run
          puts "Would update CitationsProject #{cp.id} from '#{cp.screening_status}' to 'fsu' in Project ID: #{cp.project_id}"
        else
          cp.update(screening_status: 'fsu')
        end
      end

      eligibility_map[:false].each do |ineligible_cp_id|
        cp = CitationsProject.find(ineligible_cp_id)
        if dry_run
          puts "Would update CitationsProject #{cp.id} from '#{cp.screening_status}' to 'asr' in Project ID: #{cp.project_id}"
        else
          cp.update(screening_status: 'asr')
        end
      end

      # Bulk reindex all affected records
      unless dry_run
        CitationsProject.where(project_id: project.id).reindex
      end

      puts "\nTotal records processed:"
      puts "\nasps -> fsu: #{eligibility_map[:true].size}"
      puts "\nasps -> asr: #{eligibility_map[:false].size}"
    end

    def advance_eligible_citations_to_full_text_for_abstract_screening(abstract_screening_id, dry_run: false)
      abstract_screening = AbstractScreening.find(abstract_screening_id)
      eligibility_map = {
        true: [],
        false: [],
        skip: []
      }

      asps_cps = get_asps_citations_for_abstract_screening(abstract_screening)

      asps_cps.each do |cp|
        eligibility = check_eligibility_of_cp(cp)
        if eligibility == :skip
          puts "Skipping CitationsProject #{cp.id} due to label = 0" if dry_run
          eligibility_map[:skip].push(cp.id)
        else
          eligibility_map[eligibility].push(cp.id)
        end
      end

      puts "\nDRY RUN SUMMARY:" if dry_run
      eligibility_map[:true].each do |eligible_cp_id|
        cp = CitationsProject.find(eligible_cp_id)
        if dry_run
          puts "Would update CitationsProject #{cp.id} from '#{cp.screening_status}' to 'fsu' (abstract_screening: #{abstract_screening_id})"
        else
          cp.update(screening_status: 'fsu')
        end
      end

      eligibility_map[:false].each do |ineligible_cp_id|
        cp = CitationsProject.find(ineligible_cp_id)
        if dry_run
          puts "Would update CitationsProject #{cp.id} from '#{cp.screening_status}' to 'asr' (abstract_screening: #{abstract_screening_id})"
        else
          cp.update(screening_status: 'asr')
        end
      end

      unless dry_run
        CitationsProject.where(id: eligibility_map.values.flatten).reindex
      end

      puts "\nTotal records processed for AbstractScreening ##{abstract_screening_id}:"
      puts "\nasps -> fsu: #{eligibility_map[:true].size}"
      puts "\nasps -> asr: #{eligibility_map[:false].size}"
      puts "\nskipped due to label = 0: #{eligibility_map[:skip].size}"
    end

    def reset_asr_fsu_citations_for_abstract_screening(abstract_screening_id, dry_run: false)
      abstract_screening = AbstractScreening.find(abstract_screening_id)
      asr_fsu_cps = abstract_screening.citations_projects.where(screening_status: ['asr', 'fsu'])

      asr_fsu_cps.each do |cp|
        if cp.abstract_screening_results.size >= 2
          raise "Too many abstract screening results for CitationsProject #{cp.id}"
        end

        if cp.abstract_screening_results.empty?
          raise "Not enough abstract screening results for CitationsProject #{cp.id}"
        end

        unless cp.screening_qualifications.empty?
          if dry_run
            puts "Would delete screening_qualifications for CitationsProject #{cp.id}"
          else
            cp.screening_qualifications.destroy_all
            puts "Deleted screening_qualifications for CitationsProject #{cp.id}"
          end
        end

        if dry_run
          puts "Would update CitationsProject #{cp.id} from '#{cp.screening_status}' to 'asps' (abstract_screening: #{abstract_screening_id})"
        else
          cp.update(screening_status: 'asps')
        end
      end

      unless dry_run
        CitationsProject.where(id: asr_fsu_cps.map(&:id)).reindex
      end
    end

    def delete_nil_label_results_for_abstract_screening(abstract_screening_id, dry_run: false)
      abstract_screening = AbstractScreening.find(abstract_screening_id)

      results_to_delete = abstract_screening.abstract_screening_results.where(label: nil)

      if results_to_delete.empty?
        puts "No abstract_screening_results with label nil found for AbstractScreening ##{abstract_screening_id}."
        return
      end

      results_to_delete.each do |result|
        if dry_run
          puts "Would delete AbstractScreeningResult ##{result.id} with label nil for AbstractScreening ##{abstract_screening_id}."
        else
          result.destroy
          puts "Deleted AbstractScreeningResult ##{result.id} with label nil for AbstractScreening ##{abstract_screening_id}."
        end
      end

      puts "#{results_to_delete.size} AbstractScreeningResults with label nil processed for AbstractScreening ##{abstract_screening_id}."
    end

    private

    def check_eligibility_of_cp(cp)
      raise 'Too many abstract screening results' if cp.abstract_screening_results.size > 1
      raise 'Not enough abstract screening results' if cp.abstract_screening_results.empty?

      case cp.abstract_screening_results.first.label
      when -1
        return :false
      when 1
        return :true
      else
        return :skip
      end
    end

    # Helper method to find all citations_projects records for @project that
    # have status 'asps'.
    def get_asps_citations_for_project(project)
      project.citations_projects.where('screening_status = ?', 'asps')
    end

    def get_asps_citations_for_abstract_screening(abstract_screening)
      abstract_screening.citations_projects.where(screening_status: 'asps')
    end
  end
end
