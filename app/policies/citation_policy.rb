class CitationPolicy < ApplicationPolicy
  def index?
    project_contributor?
  end

  def labeled?
    project_contributor?
  end

  def unlabled?
    project_contributor?
  end
end
