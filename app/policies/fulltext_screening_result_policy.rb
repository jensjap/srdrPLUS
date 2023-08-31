class FulltextScreeningResultPolicy < ApplicationPolicy
  def show?
    part_of_project?
  end

  def update?
    @record.user == @user
  end
end
