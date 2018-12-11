class CitationPolicy < ApplicationPolicy
  def labeled?
    project_contributor?
  end

  def unlabled?
    project_contributor?
  end
end
