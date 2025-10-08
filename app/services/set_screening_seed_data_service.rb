# SeedScreeningService
# This service is responsible for seeding screening data into the application.
# It will accomplish this by searching for citations without ASR that have been
# moved along in the process (i.e. have a screening status of 'eip' or similar)
class SetScreeningSeedDataService
  def self.main(project_id=0)
    return 'No project id provided' if project_id.eql?(0)

    project = Project.find(project_id)
    return 'Project not found' if project.nil?

    seed_project(project)
  rescue StandardError => e
    puts "Error in SetScreeningSeedDataService: #{e.message}"
  end

  private

  def self.seed_project(project)
    # This method will seed screening data for the given project,
    # i.e. it will create ASR for citations that do not have it.
    puts "Seeding project: #{project.name}"

    citations_projects = CitationsProject.where(project_id: project.id)
    return 'No citations projects found' if citations_projects.empty?

    # This array will hold citations projects that need ASR.
    cps_needing_asr = find_cps_needing_asr(citations_projects)

    return 'No citations projects need ASR' if cps_needing_asr.empty?
    create_asr(cps_needing_asr)
  rescue StandardError => e
    puts "Error seeding project: #{e.message}"
  end

  def self.create_asr(citations_projects)
    acceptance_candidates, rejection_candidates = sort_citations_projects(citations_projects)
    as = AbstractScreening.find_or_create_by(
      project_id: citations_projects.first.project_id,
      abstract_screening_type: 'single-perpetual'
    )

    acceptance_candidates.each do |acceptance_candidate|
      AbstractScreeningResult.create!(
        abstract_screening_id: as.id,
        user_id: 1,
        citations_project_id: acceptance_candidate.id,
        label: 1,
        notes: 'Seeded ASR',
        privileged: false,
        form_complete: false
      )
    end

    rejection_candidates.each do |rejection_candidate|
      AbstractScreeningResult.create!(
        abstract_screening_id: as.id,
        user_id: 1,
        citations_project_id: rejection_candidate.id,
        label: -1,
        notes: 'Seeded ASR',
        privileged: false,
        form_complete: false
      )
    end
  rescue StandardError => e
    puts "Error creating ASR: #{e.message}"
  end

  def self.sort_citations_projects(citations_projects)
    # This method will sort citations projects into acceptance and rejection candidates.
    acceptance_candidates = []
    rejection_candidates = []

    citations_projects.each do |citations_project|
      if citations_project.screening_status == 'asr'
        rejection_candidates << citations_project
      else
        acceptance_candidates << citations_project
      end
    end

    [acceptance_candidates, rejection_candidates]
  rescue StandardError => e
    puts "Error sorting citations projects: #{e.message}"
  end

  def self.find_cps_needing_asr(citations_projects)
    # This method will filter citations projects that need ASR.
    cps_needing_asr = []
    citations_projects.each do |citations_project|
      if citations_project.screening_status != 'asu' && citations_project.abstract_screening_results.empty?
        cps_needing_asr << citations_project
      end
    end
    puts "Found #{cps_needing_asr.count} citations projects needing ASR"
    cps_needing_asr
  rescue StandardError => e
    puts "Error finding citations projects needing ASR: #{e.message}"
  end
end