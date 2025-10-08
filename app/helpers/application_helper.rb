module ApplicationHelper
  def project_blacklisted?(project_id)
    if ENV['BLACKLISTED_PROJECT_IDS']&.split(',')&.map(&:to_i)&.include?(project_id)
      redirect_to projects_path
      return true
    end

    return false
  end
end
