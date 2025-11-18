require 'rails_helper'

RSpec.describe 'Project Deletion', type: :model do
  describe '#destroy' do
    context 'with a simple project' do
      let!(:project) { create(:project) }

      it 'successfully deletes the project' do
        expect { project.destroy }.to change { Project.count }.by(-1)
      end

      it 'removes the project from the database' do
        project_id = project.id
        project.destroy
        expect(Project.find_by(id: project_id)).to be_nil
      end
    end

    context 'with shared citations across multiple projects' do
      let!(:project1) { create(:project) }
      let!(:project2) { create(:project) }
      let!(:shared_citation) { create(:citation) }

      before do
        create(:citations_project, project: project1, citation: shared_citation)
        create(:citations_project, project: project2, citation: shared_citation)
      end

      it 'does not delete shared citations' do
        expect { project1.destroy }.not_to change { Citation.count }
        expect(Citation.exists?(shared_citation.id)).to be true
        expect(project2.citations).to include(shared_citation)
      end

      it 'deletes the citations_projects join records for project1 only' do
        project1_citation_count = project1.citations_projects.count
        project2_citation_count = project2.citations_projects.count

        expect {
          project1.destroy
        }.to change { CitationsProject.count }.by(-project1_citation_count)

        expect(project2.reload.citations_projects.count).to eq(project2_citation_count)
      end
    end

    context 'with shared extraction forms across multiple projects' do
      let!(:project1) { create(:project) }
      let!(:project2) { create(:project) }
      let!(:shared_extraction_form) { create(:extraction_form) }

      before do
        create(:extraction_forms_project, project: project1, extraction_form: shared_extraction_form)
        create(:extraction_forms_project, project: project2, extraction_form: shared_extraction_form)
      end

      it 'does not delete shared extraction forms' do
        expect { project1.destroy }.not_to change { ExtractionForm.count }
        expect(ExtractionForm.exists?(shared_extraction_form.id)).to be true
        expect(project2.extraction_forms).to include(shared_extraction_form)
      end

      it 'deletes the extraction_forms_projects join records for project1 only' do
        project1_efp_count = project1.extraction_forms_projects.count
        project2_efp_count = project2.extraction_forms_projects.count

        expect {
          project1.destroy
        }.to change { ExtractionFormsProject.count }.by(-project1_efp_count)

        expect(project2.reload.extraction_forms_projects.count).to eq(project2_efp_count)
      end
    end

    context 'with shared key questions across multiple projects' do
      let!(:project1) { create(:project) }
      let!(:project2) { create(:project) }
      let!(:shared_key_question) { KeyQuestion.create!(name: "Shared KQ #{SecureRandom.hex(4)}") }

      before do
        KeyQuestionsProject.create!(project: project1, key_question: shared_key_question)
        KeyQuestionsProject.create!(project: project2, key_question: shared_key_question)
      end

      it 'does not delete shared key questions' do
        expect { project1.destroy }.not_to change { KeyQuestion.count }
        expect(KeyQuestion.exists?(shared_key_question.id)).to be true
        expect(project2.key_questions).to include(shared_key_question)
      end

      it 'deletes the key_questions_projects join records for project1 only' do
        project1_kqp_count = project1.key_questions_projects.count
        project2_kqp_count = project2.key_questions_projects.count

        expect {
          project1.destroy
        }.to change { KeyQuestionsProject.count }.by(-project1_kqp_count)

        expect(project2.reload.key_questions_projects.count).to eq(project2_kqp_count)
      end
    end

    context 'with project-specific data' do
      let!(:project) { create(:project) }
      let!(:citation) { create(:citation) }
      let!(:citations_project) { create(:citations_project, project: project, citation: citation) }
      let!(:user) { User.first || User.create!(email: 'test@example.com', password: 'password123') }

      let!(:extraction1) do
        Extraction.create!(
          project: project,
          citations_project: citations_project,
          user: user
        )
      end

      let!(:extraction2) do
        Extraction.create!(
          project: project,
          citations_project: citations_project,
          user: user
        )
      end

      it 'deletes all extractions belonging to the project' do
        extraction_count = project.extractions.count
        expect(extraction_count).to eq(2)

        expect {
          project.destroy
        }.to change { Extraction.count }.by(-extraction_count)

        expect(Extraction.exists?(extraction1.id)).to be false
        expect(Extraction.exists?(extraction2.id)).to be false
      end

      it 'deletes the citations_projects join record' do
        expect {
          project.destroy
        }.to change { CitationsProject.count }.by(-1)

        expect(CitationsProject.exists?(citations_project.id)).to be false
      end

      it 'does not delete the citation itself' do
        expect {
          project.destroy
        }.not_to change { Citation.count }

        expect(Citation.exists?(citation.id)).to be true
      end
    end

    context 'with extraction forms and sections' do
      let!(:project) { create(:project) }
      let!(:extraction_form) { create(:extraction_form) }
      let!(:extraction_forms_project) do
        create(:extraction_forms_project,
               project: project,
               extraction_form: extraction_form)
      end

      it 'deletes extraction_forms_projects records' do
        # Count how many EFPs belong to this project
        efp_count = project.extraction_forms_projects.count

        expect {
          project.destroy
        }.to change { ExtractionFormsProject.count }.by(-efp_count)

        expect(ExtractionFormsProject.exists?(extraction_forms_project.id)).to be false
      end

      it 'does not delete the extraction form itself' do
        expect {
          project.destroy
        }.not_to change { ExtractionForm.count }

        expect(ExtractionForm.exists?(extraction_form.id)).to be true
      end
    end

    context 'with projects_users associations' do
      let!(:project) { create(:project) }
      let!(:user1) { User.first || User.create!(email: 'user1@example.com', password: 'password123') }
      let!(:user2) { User.create!(email: 'user2@example.com', password: 'password123') }

      before do
        ProjectsUser.create!(project: project, user: user1, permissions: 1)
        ProjectsUser.create!(project: project, user: user2, permissions: 2)
      end

      it 'deletes all projects_users join records' do
        projects_user_count = project.projects_users.count
        expect(projects_user_count).to eq(2)

        expect {
          project.destroy
        }.to change { ProjectsUser.count }.by(-projects_user_count)
      end

      it 'does not delete the users themselves' do
        expect {
          project.destroy
        }.not_to change { User.count }

        expect(User.exists?(user1.id)).to be true
        expect(User.exists?(user2.id)).to be true
      end
    end

    context 'edge cases' do
      it 'handles deletion of a project with no associations' do
        project = create(:project)

        expect { project.destroy }.not_to raise_error
        expect(Project.exists?(project.id)).to be false
      end

      it 'properly cascades deletion through multiple levels' do
        project = create(:project)
        citation = create(:citation)
        cp = create(:citations_project, project: project, citation: citation)
        user = User.first || User.create!(email: 'test@example.com', password: 'password123')

        extraction = Extraction.create!(
          project: project,
          citations_project: cp,
          user: user
        )

        # This will test the cascade: Project -> Extraction -> ExtractionChecksum
        expect(extraction.extraction_checksum).to be_present

        checksum_id = extraction.extraction_checksum.id

        project.destroy

        expect(ExtractionChecksum.exists?(checksum_id)).to be false
      end
    end
  end
end
