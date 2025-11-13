require 'rails_helper'

# Tests for population timepoint management in outcomes
#
# These tests verify that:
# 1. Populations always have at least 1 timepoint (either user-provided or default baseline)
# 2. Default baseline timepoint is created when user doesn't provide timepoints
# 3. User-provided timepoints take precedence over default baseline
# 4. Subsequent populations copy timepoints from the first population
# 5. Validation prevents deleting the last timepoint
RSpec.describe ExtractionsExtractionFormsProjectsSectionsType1Row, type: :model do
  describe 'timepoint management' do
    # Skip callbacks that require complex setup
    before do
      allow_any_instance_of(Project).to receive(:create_default_extraction_form).and_return(true)
      allow_any_instance_of(ExtractionFormsProject).to receive(:create_default_arms).and_return(true)
    end

    let(:outcome) { create_test_outcome }

    def create_test_outcome
      # Create minimal required data structure for an outcome
      user = User.find_or_create_by!(email: "test#{SecureRandom.hex(8)}@example.com") do |u|
        u.password = 'password123456'
        u.password_confirmation = 'password123456'
      end

      project = Project.create!(name: "Test Project #{SecureRandom.hex(8)}")
      ProjectsUser.create!(project: project, user: user)

      citation = Citation.create!(name: "Citation #{SecureRandom.hex(8)}")
      cp = CitationsProject.create!(citation: citation, project: project)
      extraction = Extraction.create!(citations_project: cp, project: project)

      ef = ExtractionForm.find_or_create_by!(name: 'ef1')
      efpt = ExtractionFormsProjectType.find_or_create_by!(name: 'Standard')
      efp = ExtractionFormsProject.create!(
        extraction_form: ef,
        project: project,
        extraction_forms_project_type: efpt,
        create_empty: true
      )

      section = Section.find_or_create_by!(name: 'Outcomes', default: true)
      efpst = ExtractionFormsProjectsSectionType.find_or_create_by!(name: 'Type1')
      efps = ExtractionFormsProjectsSection.create!(
        extraction_forms_project: efp,
        section: section,
        extraction_forms_projects_section_type: efpst,
        pos: 1
      )

      eefps = ExtractionsExtractionFormsProjectsSection.create!(
        extraction: extraction,
        extraction_forms_projects_section: efps
      )

      type1 = Type1.find_or_create_by!(name: "Outcome #{SecureRandom.hex(8)}", description: "Test outcome")
      type1_type = Type1Type.first || Type1Type.create!(name: "Default Type")

      # Create outcome and remove auto-created population for clean slate
      eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.create!(
        extractions_extraction_forms_projects_section: eefps,
        type1: type1,
        type1_type: type1_type
      )

      # Delete any auto-created populations to have a clean slate
      eefpst1.extractions_extraction_forms_projects_sections_type1_rows.destroy_all
      eefpst1.reload

      eefpst1
    end

    describe 'default baseline timepoint creation' do
      context 'when creating the first population without timepoints' do
        it 'creates a default baseline timepoint' do
          pop_name = PopulationName.create!(name: "Population #{SecureRandom.hex(8)}", description: "Test")

          population = outcome.extractions_extraction_forms_projects_sections_type1_rows.create!(
            population_name: pop_name
          )

          population.reload
          timepoints = population.extractions_extraction_forms_projects_sections_type1_row_columns

          expect(timepoints.count).to eq(1)
          expect(timepoints.first.timepoint_name.name).to eq('Baseline')
          expect(timepoints.first.timepoint_name.unit).to eq('')
        end
      end

      context 'when creating a population with user-provided timepoints' do
        it 'uses user timepoints instead of creating default baseline' do
          tp1 = TimepointName.find_or_create_by!(name: '6 months', unit: 'months')
          tp2 = TimepointName.find_or_create_by!(name: '12 months', unit: 'months')
          pop_name = PopulationName.create!(name: "Population #{SecureRandom.hex(8)}", description: "Test")

          population = outcome.extractions_extraction_forms_projects_sections_type1_rows.create!(
            population_name: pop_name,
            extractions_extraction_forms_projects_sections_type1_row_columns_attributes: [
              { timepoint_name_id: tp1.id },
              { timepoint_name_id: tp2.id }
            ]
          )

          population.reload
          timepoints = population.extractions_extraction_forms_projects_sections_type1_row_columns

          expect(timepoints.count).to eq(2)
          expect(timepoints.map { |tp| tp.timepoint_name.name }).to match_array(['6 months', '12 months'])
          expect(timepoints.map { |tp| tp.timepoint_name.name }).not_to include('Baseline')
        end
      end

      context 'when creating subsequent populations' do
        it 'copies timepoints from the first population' do
          # Create first population with custom timepoints
          tp1 = TimepointName.find_or_create_by!(name: 'Baseline', unit: '')
          tp2 = TimepointName.find_or_create_by!(name: '3', unit: 'years')
          pop_name1 = PopulationName.create!(name: "Population 1 #{SecureRandom.hex(8)}", description: "Test")

          first_population = outcome.extractions_extraction_forms_projects_sections_type1_rows.create!(
            population_name: pop_name1,
            extractions_extraction_forms_projects_sections_type1_row_columns_attributes: [
              { timepoint_name_id: tp1.id },
              { timepoint_name_id: tp2.id }
            ]
          )

          # Create second population without specifying timepoints
          pop_name2 = PopulationName.create!(name: "Population 2 #{SecureRandom.hex(8)}", description: "Test")

          second_population = outcome.extractions_extraction_forms_projects_sections_type1_rows.create!(
            population_name: pop_name2
          )

          second_population.reload
          timepoints = second_population.extractions_extraction_forms_projects_sections_type1_row_columns

          expect(timepoints.count).to eq(2)
          expect(timepoints.map { |tp| tp.timepoint_name.name }).to match_array(['Baseline', '3'])
        end
      end
    end

    describe 'timepoint validation' do
      context 'when attempting to delete all timepoints' do
        it 'prevents deletion with validation error' do
          pop_name = PopulationName.create!(name: "Population #{SecureRandom.hex(8)}", description: "Test")
          tp1 = TimepointName.find_or_create_by!(name: 'Baseline', unit: '')
          tp2 = TimepointName.find_or_create_by!(name: '6 months', unit: 'months')

          population = outcome.extractions_extraction_forms_projects_sections_type1_rows.create!(
            population_name: pop_name,
            extractions_extraction_forms_projects_sections_type1_row_columns_attributes: [
              { timepoint_name_id: tp1.id },
              { timepoint_name_id: tp2.id }
            ]
          )

          population.reload

          # Mark all timepoints for destruction
          population.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
            tp.mark_for_destruction
          end

          expect(population).not_to be_valid
          expect(population.errors.full_messages).to include('Must keep at least one timepoint')
        end
      end

      context 'when keeping at least one timepoint' do
        it 'allows deletion of some timepoints' do
          pop_name = PopulationName.create!(name: "Population #{SecureRandom.hex(8)}", description: "Test")
          tp1 = TimepointName.find_or_create_by!(name: 'Baseline', unit: '')
          tp2 = TimepointName.find_or_create_by!(name: '6 months', unit: 'months')

          population = outcome.extractions_extraction_forms_projects_sections_type1_rows.create!(
            population_name: pop_name,
            extractions_extraction_forms_projects_sections_type1_row_columns_attributes: [
              { timepoint_name_id: tp1.id },
              { timepoint_name_id: tp2.id }
            ]
          )

          population.reload

          # Mark only one timepoint for destruction
          population.extractions_extraction_forms_projects_sections_type1_row_columns.last.mark_for_destruction

          expect(population).to be_valid
        end
      end

      context 'when validation runs on create' do
        it 'does not run the timepoint validation' do
          # The validation only runs on :update, not on :create
          pop_name = PopulationName.create!(name: "Population #{SecureRandom.hex(8)}", description: "Test")

          # This should succeed even though we're not providing timepoints initially
          # because the after_save callback will create the default baseline
          population = outcome.extractions_extraction_forms_projects_sections_type1_rows.create!(
            population_name: pop_name
          )

          expect(population).to be_persisted
          expect(population.extractions_extraction_forms_projects_sections_type1_row_columns.count).to eq(1)
        end
      end
    end

    describe 'edge cases' do
      context 'when outcome section name is not Outcomes or Diagnoses' do
        it 'does not create default timepoints' do
          # Create a different section type (not Outcomes or Diagnoses)
          user = User.find_or_create_by!(email: "test#{SecureRandom.hex(8)}@example.com") do |u|
            u.password = 'password123456'
            u.password_confirmation = 'password123456'
          end

          project = Project.create!(name: "Test Project #{SecureRandom.hex(8)}")
          ProjectsUser.create!(project: project, user: user)

          citation = Citation.create!(name: "Citation #{SecureRandom.hex(8)}")
          cp = CitationsProject.create!(citation: citation, project: project)
          extraction = Extraction.create!(citations_project: cp, project: project)

          ef = ExtractionForm.find_or_create_by!(name: 'ef1')
          efpt = ExtractionFormsProjectType.find_or_create_by!(name: 'Standard')
          efp = ExtractionFormsProject.create!(
            extraction_form: ef,
            project: project,
            extraction_forms_project_type: efpt,
            create_empty: true
          )

          # Create a different section (not Outcomes/Diagnoses)
          section = Section.create!(name: "Other Section #{SecureRandom.hex(8)}", default: false)
          efpst = ExtractionFormsProjectsSectionType.find_or_create_by!(name: 'Type1')
          efps = ExtractionFormsProjectsSection.create!(
            extraction_forms_project: efp,
            section: section,
            extraction_forms_projects_section_type: efpst,
            pos: 1
          )

          eefps = ExtractionsExtractionFormsProjectsSection.create!(
            extraction: extraction,
            extraction_forms_projects_section: efps
          )

          type1 = Type1.find_or_create_by!(name: "Type1 #{SecureRandom.hex(8)}", description: "Test")
          type1_type = Type1Type.first || Type1Type.create!(name: "Default Type")

          other_outcome = ExtractionsExtractionFormsProjectsSectionsType1.create!(
            extractions_extraction_forms_projects_section: eefps,
            type1: type1,
            type1_type: type1_type
          )

          # The create_default_type1_rows callback should not create populations for non-Outcomes sections
          expect(other_outcome.extractions_extraction_forms_projects_sections_type1_rows.count).to eq(0)
        end
      end
    end
  end
end
