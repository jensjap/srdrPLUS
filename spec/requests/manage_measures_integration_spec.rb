require 'rails_helper'

RSpec.describe 'Manage Measures Integration', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:project) { create(:project, create_empty: true) }
  let!(:projects_user) { create(:projects_user, project: project, user: user) }

  before do
    sign_in user
  end

  describe 'Managing measures via AJAX' do
    # Create a proper result section with population
    let(:extraction) { create(:extraction, project: project) }
    let(:section) { Section.find_or_create_by!(name: 'Results') }
    let(:efp) { project.extraction_forms_projects.first || create(:extraction_forms_project, project: project, extraction_forms_project_type: ExtractionFormsProjectType.first) }
    let(:efps) { create(:extraction_forms_projects_section, extraction_forms_project: efp, section: section) }
    let(:eefps) { create(:extractions_extraction_forms_projects_section, extraction: extraction, extraction_forms_projects_section: efps) }
    let(:eefpst1) { create(:extractions_extraction_forms_projects_sections_type1, extractions_extraction_forms_projects_section: eefps) }
    let!(:population) { create(:extractions_extraction_forms_projects_sections_type1_row, extractions_extraction_forms_projects_sections_type1: eefpst1) }
    let!(:result_section) do
      rsst = ResultStatisticSectionType.find_or_create_by!(name: 'Descriptive Statistics')
      population.result_statistic_sections.find_by!(result_statistic_section_type: rsst)
    end

    # Create measures
    let!(:mean_measure) { create(:measure, :mean) }
    let!(:median_measure) { create(:measure, :median) }
    let!(:sd_measure) { create(:measure, :standard_deviation) }

    before do
      # Setup available measures for this result section type
      rsst = result_section.result_statistic_section_type
      [mean_measure, median_measure, sd_measure].each do |measure|
        create(:result_statistic_section_types_measure,
               result_statistic_section_type: rsst,
               measure: measure,
               default: true)
      end
    end

    describe 'GET manage_measures' do
      it 'returns JavaScript to open the modal with available measures' do
        get manage_measures_result_statistic_section_path(result_section),
            params: { rss_id: result_section.id },
            xhr: true

        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('text/javascript')

        # Check that the response includes the modal rendering
        expect(response.body).to include('manage-measures-modal')
        expect(response.body).to include('foundation')

        # Check that the form structure is present
        expect(response.body).to include('Select measures to include in this results section')
        expect(response.body).to include('measure-search-input')
        expect(response.body).to include('select-all-measures')
        expect(response.body).to include('deselect-all-measures')
      end
    end

    # TODO: Additional tests for updating measures require proper authorization setup
    # The result_section needs to belong to the same project the user is a member of.
    # Future tests should:
    # - Test adding measures via AJAX PATCH
    # - Test removing measures via AJAX PATCH
    # - Test provider/dependent measure relationships
    # - Test measures with existing data showing "Has Data" badge
    # - Test marking measures as selected when they're already in the result section
  end
end
