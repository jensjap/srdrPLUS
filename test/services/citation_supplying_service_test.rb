require 'test_helper'

class CitationSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @project = projects(:one)
    @citation = citations(:one)
    @service = CitationSupplyingService.new
  end

  test 'should find citations by project id' do
    bundle = @service.find_by_project_id(@project.id)

    assert_instance_of FHIR::Bundle, bundle
    assert_equal @project.citations.count, bundle.entry.count

    bundle.entry.each do |entry|
      assert_instance_of FHIR::Citation, entry.resource
    end
  end

  test 'should find citation by citation id' do
    citation = @service.find_by_citation_id(@citation.id)

    assert_instance_of FHIR::Citation, citation
    assert_equal @citation.id, citation.id.split('-').last.to_i
  end
end
