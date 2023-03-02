class FundingSourcesSdMetaDatumPolicy < ApplicationPolicy
  def create?
    part_of_project?
  end

  def destroy?
    part_of_project?
  end
end
