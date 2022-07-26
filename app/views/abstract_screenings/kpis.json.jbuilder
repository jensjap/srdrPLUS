json.count(@project
  .citations_projects
  .count)
json.cp(@project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::CITATION_POOL })
  .count)
json.asu(@project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING_UNSCREENED })
  .count)
json.asps @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING_PARTIALLY_SCREENED })
  .count
json.asr @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING_REJECTED })
  .count
json.asc @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING_IN_CONFLICT })
  .count
json.asa @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING_ACCEPTED })
  .count
json.ftu(@project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING_UNSCREENED })
  .count)
json.ftps @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED })
  .count
json.ftr @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING_REJECTED })
  .count
json.ftc @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING_IN_CONFLICT })
  .count
json.fta @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING_ACCEPTED })
  .count
json.denye @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::DATA_EXTRACTION_NOT_YET_EXTRACTED })
  .count
json.deip @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::DATA_EXTRACTION_IN_PROGRESS })
  .count
json.c @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::COMPLETED })
  .count
