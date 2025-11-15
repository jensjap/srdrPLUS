citations_projects = @project.citations_projects.includes(:screening_qualifications)

json.count citations_projects.count

# Progressive/cumulative counting: citations are counted in each phase they've reached or passed
# This shows the flow: Abstract → Fulltext → Extraction → Consolidation

# Abstract Screening counts
# Citations still in abstract screening phase (haven't moved to fulltext yet)
in_abstract = citations_projects.reject do |cp|
  # Has moved beyond abstract if: has FS/E qualifications OR is in FS/E/C status
  cp.screening_qualifications.any? { |sq| [ScreeningQualification::FS_ACCEPTED, ScreeningQualification::E_ACCEPTED].include?(sq.qualification_type) } ||
  %w[fsu fsps fsic fsr ene eip er cnc cip cr cc].include?(cp.screening_status)
end

json.asu in_abstract.filter { |cp| cp.screening_status == CitationsProject::AS_UNSCREENED }.count
json.asps in_abstract.filter { |cp| cp.screening_status == CitationsProject::AS_PARTIALLY_SCREENED }.count
json.asic in_abstract.filter { |cp| cp.screening_status == CitationsProject::AS_IN_CONFLICT }.count
# AS Accepted = citations that have ACTUALLY moved past abstract screening (status is beyond AS phase)
json.asa(citations_projects.filter do |cp|
  # Moved past abstract = screening_status is in FS/E/C phases
  %w[fsu fsps fsic fsr ene eip er cnc cip cr cc].include?(cp.screening_status)
end.count)
json.asr in_abstract.filter { |cp| cp.screening_status == CitationsProject::AS_REJECTED }.count

# Full-text Screening counts
# Citations in fulltext phase (have passed abstract but not yet extraction)
in_fulltext = citations_projects.select do |cp|
  # In fulltext if: has AS_ACCEPTED or FS statuses, but NOT in extraction/consolidation
  (cp.screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::AS_ACCEPTED } ||
   %w[fsu fsps fsic fsr].include?(cp.screening_status)) &&
  !cp.screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::E_ACCEPTED } &&
  !%w[ene eip er cnc cip cr cc].include?(cp.screening_status)
end

json.fsu in_fulltext.filter { |cp| cp.screening_status == CitationsProject::FS_UNSCREENED }.count
json.fsps in_fulltext.filter { |cp| cp.screening_status == CitationsProject::FS_PARTIALLY_SCREENED }.count
json.fsic in_fulltext.filter { |cp| cp.screening_status == CitationsProject::FS_IN_CONFLICT }.count
# FS Accepted = citations that have moved past fulltext screening (status is beyond FS phase)
json.fsa(citations_projects.filter do |cp|
  %w[ene eip er cnc cip cr cc].include?(cp.screening_status)
end.count)
json.fsr in_fulltext.filter { |cp| cp.screening_status == CitationsProject::FS_REJECTED }.count

# Extraction counts
# Citations in extraction phase (have passed fulltext but not yet consolidation)
in_extraction = citations_projects.select do |cp|
  # In extraction if: has FS_ACCEPTED or E statuses, but NOT in consolidation
  (cp.screening_qualifications.any? { |sq| sq.qualification_type == ScreeningQualification::FS_ACCEPTED } ||
   %w[ene eip er].include?(cp.screening_status)) &&
  !%w[cnc cip cr cc].include?(cp.screening_status)
end

json.ene in_extraction.filter { |cp| cp.screening_status == CitationsProject::E_NEED_EXTRACTION }.count
json.eip in_extraction.filter { |cp| cp.screening_status == CitationsProject::E_IN_PROGRESS }.count
json.er in_extraction.filter { |cp| cp.screening_status == CitationsProject::E_REJECTED }.count
# E Complete = citations that have moved to consolidation (status is in C phase)
json.ec(citations_projects.filter do |cp|
  %w[cnc cip cr cc].include?(cp.screening_status)
end.count)

# Consolidation counts (final phase)
json.cnc citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_NEED_CONSOLIDATION }.count
json.cip citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_IN_PROGRESS }.count
json.cr citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_REJECTED }.count
json.cc citations_projects.filter { |cp| cp.screening_status == CitationsProject::C_COMPLETE }.count
