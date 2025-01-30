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
      asps_cps = get_asps_citations(project)

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

    private

    def check_eligibility_of_cp(cp)
      raise 'Too many abstract screening results' if cp.abstract_screening_results.size > 1
      raise 'Not enough abstract screening results' if cp.abstract_screening_results.empty?

      case cp.abstract_screening_results.first.label
      when -1
        return :false
      else
        return :true
      end
    end

    # Helper method to find all citations_projects records for @project that
    # have status 'asps'.
    def get_asps_citations(project)
      project.citations_projects.where('screening_status = ?', 'asps')
    end
  end
end
