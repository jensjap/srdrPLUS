class FulltextScreeningResultPolicy < ApplicationPolicy
  def show?
    part_of_project?
  end

  def update?
    project_contributor? && (@record.user == @user || (record.privileged && project_consolidator?))
  end

  def destroy?
    project_leader? && @record.user == @user
  end
end
