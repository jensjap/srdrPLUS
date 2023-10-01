class FulltextScreeningResultsTagPolicy < ApplicationPolicy
  def destroy?
    @record.fulltext_screening_result.user == @user
  end
end
