class ExtractionsExtractionFormsProjectsSectionsType1Policy < ApplicationPolicy
  def edit?
    project_contributor?
  end

  def update?
    project_contributor?
  end

  def destroy?
    project_consolidator?
  end

  def edit_timepoints?
    project_contributor?
  end

  def edit_populations?
    project_contributor?
  end

  def add_population?
    project_contributor?
  end

  def get_results_populations?
    project_auditor?
  end
end
