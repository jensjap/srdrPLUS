require 'rails_helper'

RSpec.describe CitationSupplyingService, type: :service do
  let(:project) { create(:project) }
  let(:citation) { create(:citation) }
  let(:citations_project) { create(:citations_project, project: project, citation: citation) }
  let(:service) { CitationSupplyingService.new }

  describe '#find_by_project_id' do
    it 'should find citations by project id' do
      # Ensure citation is associated with project
      citations_project
      bundle = service.find_by_project_id(project.id)

      expect(bundle['entry'].count).to eq(project.citations.count)
    end
  end

  describe '#find_by_citation_id' do
    it 'should find citation by citation id' do
      result = service.find_by_citation_id(citation.id)

      expect(result['id'].split('-').last.to_i).to eq(citation.id)
    end
  end
end
