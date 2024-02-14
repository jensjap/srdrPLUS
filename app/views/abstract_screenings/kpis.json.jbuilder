citations_projects = @project.citations_projects.includes(:screening_qualifications)

json.count citations_projects.count

json.asu citations_projects.filter { |cp| cp.screening_status == CitationsProject::AS_UNSCREENED }.count
json.asps citations_projects.filter { |cp| cp.screening_status == CitationsProject::AS_PARTIALLY_SCREENED }.count
json.asic citations_projects.filter { |cp| cp.screening_status == CitationsProject::AS_IN_CONFLICT }.count
json.asa(citations_projects.filter do |cp|
  cp.screening_qualifications.any? do |sq|
    sq.qualification_type == ScreeningQualification::AS_ACCEPTED
  end
end.count)
json.asr citations_projects.filter { |cp| cp.screening_status == CitationsProject::AS_REJECTED }.count

json.fsu citations_projects.filter { |cp| cp.screening_status == CitationsProject::FS_UNSCREENED }.count
json.fsps citations_projects.filter { |cp| cp.screening_status == CitationsProject::FS_PARTIALLY_SCREENED }.count
json.fsic citations_projects.filter { |cp| cp.screening_status == CitationsProject::FS_IN_CONFLICT }.count
json.fsa(citations_projects.filter do |cp|
  cp.screening_qualifications.any? do |sq|
    sq.qualification_type == ScreeningQualification::FS_ACCEPTED
  end
end.count)
json.fsr citations_projects.filter { |cp| cp.screening_status == CitationsProject::FS_REJECTED }.count

json.ene citations_projects.filter { |cp| cp.screening_status == CitationsProject::E_NEED_EXTRACTION }.count
json.eip citations_projects.filter { |cp| cp.screening_status == CitationsProject::E_IN_PROGRESS }.count
json.er citations_projects.filter { |cp| cp.screening_status == CitationsProject::E_REJECTED }.count
json.ec(citations_projects.filter do |cp|
  cp.screening_qualifications.any? do |sq|
    sq.qualification_type == ScreeningQualification::E_ACCEPTED
  end
end.count)

json.cnc citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_NEED_CONSOLIDATION }.count
json.cip citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_IN_PROGRESS }.count
json.cr citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_REJECTED }.count
json.cc citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_COMPLETE }.count
