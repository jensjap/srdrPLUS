require 'rails_helper'

RSpec.describe 'Manage Measures Interface', type: :system, js: true do
  let(:user) { create(:user) }
  let(:project) { create(:project, create_empty: true) }
  let!(:projects_user) { create(:projects_user, project: project, user: user) }

  before do
    sign_in user
    driven_by :selenium_chrome_headless
  end

  describe 'Adding and removing measures via modal' do
    # Create extraction with proper associations
    let(:extraction) { create(:extraction, project: project) }
    let(:section) { Section.find_or_create_by!(name: 'Results') }
    let(:efp) { project.extraction_forms_projects.first || create(:extraction_forms_project, project: project, extraction_forms_project_type: ExtractionFormsProjectType.first) }
    let(:efps) { create(:extraction_forms_projects_section, extraction_forms_project: efp, section: section) }
    let(:eefps) { create(:extractions_extraction_forms_projects_section, extraction: extraction, extraction_forms_projects_section: efps) }
    let(:eefpst1) { create(:extractions_extraction_forms_projects_sections_type1, extractions_extraction_forms_projects_section: eefps) }
    let!(:population) { create(:extractions_extraction_forms_projects_sections_type1_row, extractions_extraction_forms_projects_sections_type1: eefpst1) }
    let!(:result_section) do
      # The factory auto-creates result sections, so find the descriptive one
      rsst = ResultStatisticSectionType.find_or_create_by!(name: 'Descriptive Statistics')
      population.result_statistic_sections.find_by!(result_statistic_section_type: rsst)
    end

    let!(:mean_measure) { create(:measure, :mean) }
    let!(:median_measure) { create(:measure, :median) }
    let!(:sd_measure) { create(:measure, :standard_deviation) }

    before do
      # Setup available measures for the result section type
      rsst = result_section.result_statistic_section_type
      [mean_measure, median_measure, sd_measure].each do |measure|
        create(:result_statistic_section_types_measure,
               result_statistic_section_type: rsst,
               measure: measure,
               default: true)
      end

      # Navigate to the work/results page where the "(edit measures)" link exists
      visit work_extraction_path(extraction)

      # Wait for page to load by checking for a common element
      expect(page).to have_content(project.name)
    end

    scenario 'User opens manage measures modal' do
      # Debug: save screenshot to see what's on the page
      save_screenshot('/tmp/test_page.png')
      puts "Page HTML: #{page.html[0..500]}"  # Print first 500 chars
      puts "Looking for '(edit measures)' link..."

      # Check if the link exists
      if page.has_link?('(edit measures)')
        # Click the "(edit measures)" link (match: :first since there may be multiple)
        click_link '(edit measures)', match: :first

        # Wait for modal to appear
        expect(page).to have_css('#manage-measures-modal', visible: true)
        # Check for the header text from the form
        expect(page).to have_content('Select measures to include in this results section')
      else
        puts "Link '(edit measures)' not found on page"
        puts "Available links: #{page.all('a').map(&:text).join(', ')}"
        fail "The '(edit measures)' link is not present on the page. Test data may not be set up correctly."
      end
    end

    scenario 'User adds measures via checkboxes' do
      click_link '(edit measures)', match: :first

      within '#manage-measures-modal' do
        # Check measures (correct ID format from the form)
        check "result_statistic_section_measure_ids_#{mean_measure.id}"
        check "result_statistic_section_measure_ids_#{median_measure.id}"

        click_button 'Update Results Section'
      end

      # Wait for modal to close
      expect(page).not_to have_css('#manage-measures-modal', visible: true)

      # Verify measures were added
      result_section.reload
      expect(result_section.measures).to include(mean_measure, median_measure)
      expect(result_section.measures.count).to eq(2)
    end

    scenario 'User removes measures via checkboxes' do
      # First add some measures
      result_section.measures << [mean_measure, median_measure, sd_measure]
      result_section.reload

      click_link '(edit measures)'

      within '#manage-measures-modal' do
        # Uncheck one measure
        uncheck "measure_ids_#{median_measure.id}"

        click_button 'Save'
      end

      # Wait for modal to close
      expect(page).not_to have_css('#manage-measures-modal', visible: true)

      # Verify measure was removed
      result_section.reload
      expect(result_section.measures).to include(mean_measure, sd_measure)
      expect(result_section.measures).not_to include(median_measure)
      expect(result_section.measures.count).to eq(2)
    end

    scenario 'User searches for measures in the modal' do
      click_link '(edit measures)'

      within '#manage-measures-modal' do
        # Type in search box
        fill_in 'search', with: 'Mean'

        # Only "Mean" measure should be visible
        expect(page).to have_content('Mean')
        expect(page).not_to have_content('Median')

        # Clear search
        fill_in 'search', with: ''

        # All measures visible again
        expect(page).to have_content('Mean')
        expect(page).to have_content('Median')
      end
    end

    scenario 'User uses "Select All" button' do
      click_link '(edit measures)'

      within '#manage-measures-modal' do
        click_button 'Select All'

        # All checkboxes should be checked
        expect(page).to have_checked_field("measure_ids_#{mean_measure.id}")
        expect(page).to have_checked_field("measure_ids_#{median_measure.id}")
        expect(page).to have_checked_field("measure_ids_#{sd_measure.id}")

        click_button 'Save'
      end

      result_section.reload
      expect(result_section.measures.count).to eq(3)
    end

    scenario 'User uses "Deselect All" button' do
      # Add measures first
      result_section.measures << [mean_measure, median_measure]
      result_section.reload

      click_link '(edit measures)'

      within '#manage-measures-modal' do
        click_button 'Deselect All'

        # All checkboxes should be unchecked
        expect(page).not_to have_checked_field("measure_ids_#{mean_measure.id}")
        expect(page).not_to have_checked_field("measure_ids_#{median_measure.id}")

        click_button 'Save'
      end

      result_section.reload
      expect(result_section.measures.count).to eq(0)
    end

    context 'when measure has data' do
      let!(:rssm) { create(:result_statistic_sections_measure,
                          result_statistic_section: result_section,
                          measure: mean_measure) }

      before do
        # Create data for the measure
        create(:tps_arms_rssm, result_statistic_sections_measure: rssm)
        create(:tps_arms_rssm, result_statistic_sections_measure: rssm)
      end

      scenario 'Shows data count badge' do
        click_link '(edit measures)'

        within '#manage-measures-modal' do
          # Should show badge with count
          expect(page).to have_content('2') # data count
        end
      end

      scenario 'Shows confirmation dialog when removing measure with data' do
        click_link '(edit measures)'

        within '#manage-measures-modal' do
          # Uncheck measure with data
          uncheck "measure_ids_#{mean_measure.id}"

          # Accept confirmation dialog
          accept_confirm do
            click_button 'Save'
          end
        end

        result_section.reload
        expect(result_section.measures).not_to include(mean_measure)
      end

      scenario 'Database records are removed when measure is deleted' do
        initial_tps_arms_count = TpsArmsRssm.count
        initial_records_count = Record.count

        click_link '(edit measures)'

        within '#manage-measures-modal' do
          uncheck "measure_ids_#{mean_measure.id}"

          accept_confirm do
            click_button 'Save'
          end
        end

        # Verify cascade deletion
        expect(TpsArmsRssm.count).to eq(initial_tps_arms_count - 2)
        expect(Record.count).to eq(initial_records_count - 2)
      end
    end

    scenario 'Measures appear in results table after adding' do
      click_link '(edit measures)'

      within '#manage-measures-modal' do
        check "measure_ids_#{mean_measure.id}"
        click_button 'Save'
      end

      # Wait for page refresh
      sleep 1

      # Verify measure appears in the results table
      within '.results-table' do
        expect(page).to have_content('Mean')
      end
    end
  end

  describe 'Provider/Dependent Measure Relationships' do
    let(:extraction) { create(:extraction, project: project) }
    let(:population) { create(:extractions_extraction_forms_projects_sections_type1_row) }
    let!(:result_section) { create(:result_statistic_section, :descriptive, population: population) }

    let!(:total_n_measure) { create(:measure, name: 'Total N Analyzed') }
    let!(:adjusted_mean_measure) { create(:measure, name: 'Adjusted Mean') }

    before do
      rsst = result_section.result_statistic_section_type

      # Create provider measure config
      provider_rsst_measure = create(:result_statistic_section_types_measure,
                                    result_statistic_section_type: rsst,
                                    measure: total_n_measure,
                                    default: true)

      # Create dependent measure config (depends on Total N)
      create(:result_statistic_section_types_measure,
             result_statistic_section_type: rsst,
             measure: adjusted_mean_measure,
             result_statistic_section_types_measure: provider_rsst_measure,
             default: false)

      visit edit_extraction_path(extraction)
    end

    scenario 'Selecting provider auto-selects dependent measures' do
      click_link '(edit measures)'

      within '#manage-measures-modal' do
        # Check the provider measure
        check "measure_ids_#{total_n_measure.id}"

        # Dependent measure should be auto-checked
        expect(page).to have_checked_field("measure_ids_#{adjusted_mean_measure.id}")

        click_button 'Save'
      end

      result_section.reload
      expect(result_section.measures).to include(total_n_measure, adjusted_mean_measure)
    end

    scenario 'Unchecking provider unchecks dependent measures' do
      # Add both measures first
      result_section.measures << [total_n_measure, adjusted_mean_measure]
      result_section.reload

      click_link '(edit measures)'

      within '#manage-measures-modal' do
        # Uncheck the provider measure
        uncheck "measure_ids_#{total_n_measure.id}"

        # Dependent measure should be auto-unchecked
        expect(page).not_to have_checked_field("measure_ids_#{adjusted_mean_measure.id}")

        click_button 'Save'
      end

      result_section.reload
      expect(result_section.measures).to be_empty
    end

    scenario 'Database creates correct provider/dependent relationship' do
      click_link '(edit measures)'

      within '#manage-measures-modal' do
        check "measure_ids_#{total_n_measure.id}"
        click_button 'Save'
      end

      result_section.reload
      provider_rssm = result_section.result_statistic_sections_measures.find_by(measure: total_n_measure)
      dependent_rssm = result_section.result_statistic_sections_measures.find_by(measure: adjusted_mean_measure)

      expect(dependent_rssm.result_statistic_sections_measure).to eq(provider_rssm)
    end
  end

  describe 'Diagnostic Test Accuracy Projects' do
    let(:diagnostic_project) do
      create(:project, extraction_forms_project_type: create(:extraction_forms_project_type, name: 'Diagnostic Test'))
    end
    let!(:diagnostic_projects_user) { create(:projects_user, project: diagnostic_project, user: user) }
    let(:extraction) { create(:extraction, project: diagnostic_project) }
    let(:population) { create(:extractions_extraction_forms_projects_sections_type1_row) }
    let(:comparison) { create(:comparison) }
    let(:timepoint) { create(:extractions_extraction_forms_projects_sections_type1_row_column) }

    let!(:result_section) { create(:result_statistic_section,
                                   :diagnostic_test_descriptive,
                                   population: population) }

    let!(:sensitivity_measure) { create(:measure, name: 'Sensitivity') }
    let!(:specificity_measure) { create(:measure, name: 'Specificity') }

    before do
      rsst = result_section.result_statistic_section_type
      [sensitivity_measure, specificity_measure].each do |measure|
        create(:result_statistic_section_types_measure,
               result_statistic_section_type: rsst,
               measure: measure,
               default: true)
      end

      visit edit_extraction_path(extraction)
    end

    scenario 'Modal opens correctly for Diagnostic Test project' do
      click_link '(edit measures)'

      expect(page).to have_css('#manage-measures-modal', visible: true)
      expect(page).to have_content('Sensitivity')
      expect(page).to have_content('Specificity')
    end

    scenario 'User adds measures to DTA project' do
      click_link '(edit measures)'

      within '#manage-measures-modal' do
        check "measure_ids_#{sensitivity_measure.id}"
        check "measure_ids_#{specificity_measure.id}"
        click_button 'Save'
      end

      result_section.reload
      expect(result_section.measures).to include(sensitivity_measure, specificity_measure)
    end

    scenario 'User edits descriptive statistics inline' do
      # Add measures first
      rssm = create(:result_statistic_sections_measure,
                    result_statistic_section: result_section,
                    measure: sensitivity_measure)

      visit edit_extraction_path(extraction)

      within '.diagnostic-test-results' do
        # Find the input for this measure
        input = find("input[data-measure='#{sensitivity_measure.id}']")
        input.fill_in with: '85.5'
        input.send_keys(:tab) # Trigger auto-save
      end

      # Wait for save
      sleep 1

      # Verify data was saved to TpsComparisonsRssm
      tps_comparison_rssm = TpsComparisonsRssm.find_by(result_statistic_sections_measure: rssm)
      expect(tps_comparison_rssm).to be_present
      expect(tps_comparison_rssm.records.first.name).to eq('85.5')
    end

    scenario 'DTA descriptive statistics table renders correctly with selected measures' do
      # Add measures
      result_section.measures << [sensitivity_measure, specificity_measure]
      result_section.reload

      visit edit_extraction_path(extraction)

      within '.diagnostic-test-descriptive-statistics' do
        # Should show column headers for each measure
        expect(page).to have_content('Sensitivity')
        expect(page).to have_content('Specificity')

        # Should have input fields for data entry
        expect(page).to have_css("input[data-measure='#{sensitivity_measure.id}']")
        expect(page).to have_css("input[data-measure='#{specificity_measure.id}']")
      end
    end

    scenario 'Removing measures from DTA project removes correct records' do
      # Add measure with data
      rssm = create(:result_statistic_sections_measure,
                    result_statistic_section: result_section,
                    measure: sensitivity_measure)
      create(:tps_comparisons_rssm, result_statistic_sections_measure: rssm)

      initial_tps_comparisons_count = TpsComparisonsRssm.count

      click_link '(edit measures)'

      within '#manage-measures-modal' do
        uncheck "measure_ids_#{sensitivity_measure.id}"

        accept_confirm do
          click_button 'Save'
        end
      end

      # Verify cascade deletion for DTA-specific records
      expect(TpsComparisonsRssm.count).to eq(initial_tps_comparisons_count - 1)
    end
  end

  describe 'Edge Cases and Error Handling' do
    let(:extraction) { create(:extraction, project: project) }
    let(:population) { create(:extractions_extraction_forms_projects_sections_type1_row) }
    let!(:result_section) { create(:result_statistic_section, :descriptive, population: population) }
    let!(:measure) { create(:measure, :mean) }

    before do
      rsst = result_section.result_statistic_section_type
      create(:result_statistic_section_types_measure,
             result_statistic_section_type: rsst,
             measure: measure)

      visit edit_extraction_path(extraction)
    end

    scenario 'Closing modal without saving does not change measures' do
      initial_measures = result_section.measures.to_a

      click_link '(edit measures)'

      within '#manage-measures-modal' do
        check "measure_ids_#{measure.id}"
        # Close modal without saving
        find('.close-button').click
      end

      result_section.reload
      expect(result_section.measures.to_a).to eq(initial_measures)
    end

    scenario 'Canceling confirmation dialog prevents deletion' do
      rssm = create(:result_statistic_sections_measure,
                    result_statistic_section: result_section,
                    measure: measure)
      create(:tps_arms_rssm, result_statistic_sections_measure: rssm)

      click_link '(edit measures)'

      within '#manage-measures-modal' do
        uncheck "measure_ids_#{measure.id}"

        # Dismiss confirmation dialog
        dismiss_confirm do
          click_button 'Save'
        end
      end

      result_section.reload
      expect(result_section.measures).to include(measure)
    end
  end
end
