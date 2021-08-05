class ExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  def show?
    project_consolidator?
  end

  def new?
    project_leader?
  end

  def edit?
    project_leader?
  end

  def create?
    project_leader?
  end

  def update?
    project_leader?
  end

  def destroy?
    project_leader?
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
