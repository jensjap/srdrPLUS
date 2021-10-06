namespace :projects_accounting_tasks do
  desc "A project with active extractions are defined as projects with extractions that contain at least 1 arm and 1 outcome."
  task :count_projects_with_active_extractions, [] => [:environment] do |t, args|
    @h_projects = Hash.new
    puts "Projects Accounting Tasks: Count Projects with Active Extractions"
    puts ""
    puts "Total number of projects: #{ Project.all.count }"

    @projects_with_extractions = 0
    @projects_with_extractions_ready_for_extraction = 0  # This means it must have at least 1 Arm and 1 Outcome
                                                         # if Standard extraction and at least 1 Diagnostic Test
                                                         # and 1 Diagnosis if Diagnostic Test type extraction.
    Project.all.each do |project|
      check_if_project_is_active(project)
    end  # Project.all.each do |project|
    puts "Total number of projects with at least 1 extraction: #{ @projects_with_extractions }"
    puts "Total number of projects with at least 1 extraction that are ready to extract: #{ @projects_with_extractions_ready_for_extraction }"

  end  #task :count_projects_with_active_extractions, [] => [:environment] do |t, args|

  def check_if_project_is_active(project)
    b_found_active_extraction = false
    @projects_with_extractions += 1 if project.extractions.count > 0
    project.extractions.each do |extraction|
      break if b_found_active_extraction 
      if extraction.results_section_ready_for_extraction?
        b_found_active_extraction = true
        @projects_with_extractions_ready_for_extraction += 1
      end  # if extraction.results_section_ready_for_extraction?
    end  # project.extractions.each do |extraction|
  end  # def check_if_project_is_active(project)
end  # namespace :projects_tasks do

