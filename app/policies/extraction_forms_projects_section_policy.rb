require_dependency 'app/policies/modules/role_checker'

class ExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  def new?
    project_consolidator?
  end

  def edit?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def destroy?
    project_consolidator?
  end

  def preview?
    project_consolidator?
  end

  def dissociate_type1?
    project_consolidator?
  end

  def add_quality_dimension?
    project_consolidator?
  end
end
