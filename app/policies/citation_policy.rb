class CitationPolicy < ApplicationPolicy
  def index?
    project_contributor?
  end
end
