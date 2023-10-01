class AbstractScreeningResultsTagPolicy < ApplicationPolicy
  def destroy?
    @record.abstract_screening_result.user == @user
  end
end
