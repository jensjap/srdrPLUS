json.count @project.citations_projects.count
json.asu @project.citations_projects.where(screening_status: :asu).count
json.asps @project.citations_projects.where(screening_status: :asps).count
json.asic @project.citations_projects.where(screening_status: :asic).count
json.asr @project.citations_projects.where(screening_status: :asr).count
json.fsu @project.citations_projects.where(screening_status: :fsu).count
json.fsps @project.citations_projects.where(screening_status: :fsps).count
json.fsic @project.citations_projects.where(screening_status: :fsic).count
json.fsr @project.citations_projects.where(screening_status: :fsr).count
json.ene @project.citations_projects.where(screening_status: :ene).count
json.eip @project.citations_projects.where(screening_status: :eip).count
json.ec @project.citations_projects.where(screening_status: :ec).count
