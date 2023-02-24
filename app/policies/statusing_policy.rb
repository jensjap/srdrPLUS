class StatusingPolicy < ApplicationPolicy
  def update?
    extraction = case record.statusable
                 when Extraction
                   record.statusable
                 when ExtractionsExtractionFormsProjectsSection, ExtractionsExtractionFormsProjectsSectionsType1
                   record.statusable.extraction
                 else
                   raise 'Unknown statusable class!'
                 end

    extraction.assigned_to?(user) ||
      ProjectsUser.find_by(project: extraction.project, user:).permissions.to_s(2)[-1] == '1'
  end
end
