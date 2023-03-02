class SdJournalArticleUrlPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end

  def update?
    project_contributor?
  end

  def destroy?
    project_contributor?
  end
end
