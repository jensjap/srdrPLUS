json.up @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::CITATION_POOL })
  .count
json.as @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING })
  .count
json.asr @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING_REJECTED })
  .count
json.fs @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING })
  .count
json.fsr @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING_REJECTED })
  .count
json.de @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::DATA_EXTRACTION })
  .count
json.c @project
  .citations_projects
  .where(citations_projects: { screening_status: CitationsProject::COMPLETED })
  .count
