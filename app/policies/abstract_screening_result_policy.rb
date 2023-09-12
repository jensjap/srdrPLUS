class AbstractScreeningResultPolicy < ApplicationPolicy
  def show?
    part_of_project?
  end

  def update?
    @record.user == @user
  end

  def destroy?
    project_leader? && @record.user == @user
  end
end
