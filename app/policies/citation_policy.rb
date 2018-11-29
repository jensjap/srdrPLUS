class CitationPolicy < ApplicationPolicy
  def labeled?
    project_consolidator?
  end

  def unlabled?
    project_consolidator?
  end
end
