eip = @project.citations_projects.includes(:extractions).where(screening_status: CitationsProject::E_IN_PROGRESS)

json.count @project.citations_projects.count
json.asu @project.citations_projects.where(screening_status: CitationsProject::AS_UNSCREENED).count
json.asps @project.citations_projects.where(screening_status: CitationsProject::AS_PARTIALLY_SCREENED).count
json.asic @project.citations_projects.where(screening_status: CitationsProject::AS_IN_CONFLICT).count
json.asa @project
  .citations_projects
  .joins(:screening_qualifications)
  .where(screening_qualifications: { qualification_type: ScreeningQualification::AS_ACCEPTED })
  .distinct
  .count
json.asr @project.citations_projects.where(screening_status: CitationsProject::AS_REJECTED).count
json.fsu @project.citations_projects.where(screening_status: CitationsProject::FS_UNSCREENED).count
json.fsps @project.citations_projects.where(screening_status: CitationsProject::FS_PARTIALLY_SCREENED).count
json.fsic @project.citations_projects.where(screening_status: CitationsProject::FS_IN_CONFLICT).count
json.fsa @project
  .citations_projects
  .joins(:screening_qualifications)
  .where(screening_qualifications: { qualification_type: ScreeningQualification::FS_ACCEPTED })
  .distinct
  .count
json.fsr @project.citations_projects.where(screening_status: CitationsProject::FS_REJECTED).count
json.ene @project.citations_projects.where(screening_status: CitationsProject::E_NEED_EXTRACTION).count
json.eip eip.count
json.er @project.citations_projects.where(screening_status: CitationsProject::E_REJECTED).count
json.eic(eip.count { |cp| cp.extractions.any?(&:consolidated) })
json.ec @project.citations_projects.where(screening_status: CitationsProject::E_COMPLETE).count
