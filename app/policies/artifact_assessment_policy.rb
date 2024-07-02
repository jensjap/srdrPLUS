class ArtifactAssessmentPolicy < ApplicationPolicy
  def index?
    project_contributor?
  end
end
