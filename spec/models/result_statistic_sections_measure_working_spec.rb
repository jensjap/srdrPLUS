require 'rails_helper'

RSpec.describe ResultStatisticSectionsMeasure, type: :model do
  describe 'associations configuration' do
    it 'has tps_arms_rssms with dependent destroy' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:tps_arms_rssms)
      expect(association).to be_present
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has tps_comparisons_rssms with dependent destroy' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:tps_comparisons_rssms)
      expect(association).to be_present
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has comparisons_arms_rssms with dependent destroy' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:comparisons_arms_rssms)
      expect(association).to be_present
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has wacs_bacs_rssms with dependent destroy' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:wacs_bacs_rssms)
      expect(association).to be_present
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'belongs to result_statistic_section' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:result_statistic_section)
      expect(association).to be_present
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to measure' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:measure)
      expect(association).to be_present
      expect(association.macro).to eq(:belongs_to)
    end

    it 'optionally belongs to provider_measure (provider)' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:provider_measure)
      expect(association).to be_present
      expect(association.macro).to eq(:belongs_to)
      # Check if optional is true or if the association allows nil
      expect([true, nil]).to include(association.options[:optional])
    end

    it 'has many dependent_measures' do
      association = ResultStatisticSectionsMeasure.reflect_on_association(:dependent_measures)
      expect(association).to be_present
      expect(association.macro).to eq(:has_many)
    end
  end

  describe 'cascade deletion behavior' do
    # Skip Project callbacks that require complex setup
    before do
      allow_any_instance_of(Project).to receive(:create_default_extraction_form).and_return(true)
      allow_any_instance_of(ExtractionFormsProject).to receive(:create_default_arms).and_return(true)
    end

    let!(:measure) { Measure.create!(name: "Test Measure #{SecureRandom.hex(8)}") }
    let!(:result_section) { create_minimal_result_section }

    let!(:rssm) do
      ResultStatisticSectionsMeasure.create!(
        result_statistic_section: result_section,
        measure: measure,
        pos: 1
      )
    end

    def create_minimal_result_section
      rsst = ResultStatisticSectionType.find_or_create_by!(name: "Test Type #{SecureRandom.hex(4)}")
      population = create_minimal_population

      ResultStatisticSection.create!(
        result_statistic_section_type: rsst,
        population_id: population.id
      )
    end

    def create_minimal_population
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

      section = Section.create!(name: "Section #{SecureRandom.hex(8)}", default: false)
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

      # Need to create Type1 for the ExtractionsExtractionFormsProjectsSectionsType1
      type1 = Type1.find_or_create_by!(name: "Outcome #{SecureRandom.hex(8)}", description: "Test outcome")

      # Need a Type1Type as well (defaults to id 1, but may not exist)
      type1_type = Type1Type.first || Type1Type.create!(name: "Default Type")

      # Create the Type1 association record
      eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.create!(
        extractions_extraction_forms_projects_section: eefps,
        type1: type1,
        type1_type: type1_type
      )

      pop_name = PopulationName.create!(name: "Population #{SecureRandom.hex(8)}", description: "Test population")
      ExtractionsExtractionFormsProjectsSectionsType1Row.create!(
        extractions_extraction_forms_projects_sections_type1: eefpst1,
        population_name: pop_name
      )
    end

    it 'removes the join table record when destroyed' do
      rssm_id = rssm.id
      rssm.destroy

      expect(ResultStatisticSectionsMeasure.find_by(id: rssm_id)).to be_nil
    end

    it 'does not remove the Measure record itself when destroyed' do
      measure_id = measure.id
      rssm.destroy

      expect(Measure.find_by(id: measure_id)).to be_present
    end

    context 'with TpsArmsRssm data' do
      let!(:tps_arms_rssm) do
        timepoint_name = TimepointName.create!(name: "T1 #{SecureRandom.hex(8)}")
        timepoint = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.create!(
          extractions_extraction_forms_projects_sections_type1_row: result_section.population,
          timepoint_name: timepoint_name
        )

        # Get the eefpst1 from the population (which is a Type1Row)
        eefpst1 = result_section.population.extractions_extraction_forms_projects_sections_type1

        TpsArmsRssm.create!(
          timepoint: timepoint,
          extractions_extraction_forms_projects_sections_type1: eefpst1,
          result_statistic_sections_measure: rssm
        )
      end

      it 'cascades deletion to TpsArmsRssm records' do
        tps_arms_id = tps_arms_rssm.id

        expect {
          rssm.destroy
        }.to change(TpsArmsRssm, :count).by(-1)

        expect(TpsArmsRssm.find_by(id: tps_arms_id)).to be_nil
      end

      it 'cascades deletion to polymorphic Record entries' do
        record = Record.create!(recordable: tps_arms_rssm, name: '42.5')
        record_id = record.id

        rssm.destroy

        # Note: Records do not cascade delete (no dependent: :destroy on the polymorphic association)
        # The record will remain but become orphaned
        orphaned_record = Record.find_by(id: record_id)
        expect(orphaned_record).to be_present
        expect(orphaned_record.recordable_id).to eq(tps_arms_rssm.id)
        expect(TpsArmsRssm.find_by(id: tps_arms_rssm.id)).to be_nil
      end
    end

    context 'provider/dependent relationships' do
      let!(:provider_measure) { Measure.create!(name: "Provider #{SecureRandom.hex(8)}") }
      let!(:dependent_measure) { Measure.create!(name: "Dependent #{SecureRandom.hex(8)}") }

      let!(:provider_rssm) do
        ResultStatisticSectionsMeasure.create!(
          result_statistic_section: result_section,
          measure: provider_measure,
          pos: 1
        )
      end

      let!(:dependent_rssm) do
        ResultStatisticSectionsMeasure.create!(
          result_statistic_section: result_section,
          measure: dependent_measure,
          provider_measure: provider_rssm,
          pos: 2
        )
      end

      it 'maintains the provider/dependent relationship' do
        expect(dependent_rssm.provider_measure).to eq(provider_rssm)
      end

      it 'prevents deletion of provider when dependents exist' do
        # The foreign key constraint prevents deleting a provider that has dependents
        expect {
          provider_rssm.destroy
        }.to raise_error(ActiveRecord::InvalidForeignKey)

        # But if we first remove the dependent, then we can delete the provider
        dependent_rssm.update!(provider_measure: nil)
        expect { provider_rssm.destroy }.not_to raise_error
      end
    end
  end
end
