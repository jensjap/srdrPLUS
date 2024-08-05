require 'test_helper'

class ProjectCloningServiceTest < ActiveSupport::TestCase
  setup do
    @original_project = projects(:copy_project_original)
    @user1 = users(:one)
    @user2 = users(:two)
    @leaders = [@user1, @user2]
  end

  test 'cloning project should create the correct number of new db records' do
    # Count starting point objects.
    p_cnt = Project.all.size
    pu_cnt = ProjectsUser.all.size
    kqp_cnt = KeyQuestionsProject.all.size
    efp_cnt = ExtractionFormsProject.all.size
    cp_cnt = CitationsProject.all.size
    ex_cnt = Extraction.all.size
    pt_cnt = ProjectsTag.all.size
    pr_cnt = ProjectsReason.all.size
    mdp_cnt = MeshDescriptorsProject.all.size

    # Just a sanity check to ensure we start with known counts of the :through associations.
    assert_equal(2, @original_project.key_questions.size)
    assert_equal(4, @original_project.citations.size)
    assert_equal(2, @original_project.tags.size)
    assert_equal(3, @original_project.reasons.size)
    assert_equal(3, @original_project.mesh_descriptors.size)
    assert_equal(5, @original_project.extractions.size)
    assert_equal(4, @original_project.extraction_forms_projects.size)

    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: false,
      include_labels: false
    }
    ProjectCloningService.clone_project(@original_project, @leaders, opts)

    assert_equal(p_cnt + 1, Project.all.size)
    assert_equal(cp_cnt + CitationsProject.where(project: @original_project).size, CitationsProject.all.size)
    assert_equal(pu_cnt + 2, ProjectsUser.all.size)
    assert_equal(kqp_cnt + KeyQuestionsProject.where(project: @original_project).size, KeyQuestionsProject.all.size)
    assert_equal(pt_cnt + ProjectsTag.where(project: @original_project).size, ProjectsTag.all.size)
    assert_equal(pr_cnt + ProjectsReason.where(project: @original_project).size, ProjectsReason.all.size)
    assert_equal(mdp_cnt + MeshDescriptorsProject.where(project: @original_project).size, MeshDescriptorsProject.all.size)
    assert_equal(ex_cnt, Extraction.all.size)
    assert_equal(efp_cnt + ExtractionFormsProject.where(project: @original_project).size, ExtractionFormsProject.all.size)
  end

  test 'cloning project with extractions should create new extraction records' do
    ex_cnt = Extraction.all.size

    # Just a sanity check to ensure we start with known counts of the :through associations.
    assert_equal(5, @original_project.extractions.size)

    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: true,
      include_labels: false
    }
    ProjectCloningService.clone_project(@original_project, @leaders, opts)

    assert_equal(ex_cnt + Extraction.where(project: @original_project).size, Extraction.all.size)
  end

  test 'cloning project should copy ExtractionFormsProjectsSection' do
    efps_cnt = ExtractionFormsProjectsSection.all.size

    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: false,
      include_labels: false
    }
    cloned_prj = ProjectCloningService.clone_project(@original_project, @leaders, opts)
    cloned_std_efp = cloned_prj
                       .extraction_forms_projects
                       .joins(:extraction_form)
                       .find_by(extraction_forms: { name: 'Standard' })
    cloned_std_efp_efps = cloned_std_efp.extraction_forms_projects_sections
    original_std_efp = @original_project
                         .extraction_forms_projects
                         .joins(:extraction_form)
                         .find_by(extraction_forms: { name: 'Standard' })
    original_std_efp_efps = original_std_efp.extraction_forms_projects_sections

    assert_equal(
      original_std_efp_efps.size,
      cloned_std_efp_efps.size
    )
    assert_equal(
      efps_cnt + original_std_efp_efps.size,
      ExtractionFormsProjectsSection.all.size
    )

    original_std_efp_efps.each do |orig_efps|
      name = orig_efps.section.name

      assert_equal(
        cloned_std_efp_efps
        .joins(:section)
        .find_by(sections: { name: })
        .extraction_forms_projects_section_option.by_type1,
        orig_efps.extraction_forms_projects_section_option.by_type1
      )
    end
  end

  test 'type1 suggestions should be copied' do
    original_efpst1_cnt = ExtractionFormsProjectsSectionsType1.all.size
    amoeba_efpst1_cnt = ExtractionFormsProjectsSectionsType1.where(
      extraction_forms_projects_section:
        @original_project
        .extraction_forms_projects
        .joins(:extraction_form)
        .where(extraction_form: { name: ExtractionForm::STANDARD })
        .first&.extraction_forms_projects_sections
    ).size

    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: false,
      include_labels: false
    }
    ProjectCloningService.clone_project(@original_project, @leaders, opts)

    assert_equal(original_efpst1_cnt + amoeba_efpst1_cnt, ExtractionFormsProjectsSectionsType1.all.size)
    refute_equal(original_efpst1_cnt, ExtractionFormsProjectsSectionsType1.all.size)
  end

  test 'destroying cloned project should delete the correct number of database records' do
    # Count starting point objects.
    p_cnt = Project.all.size
    pu_cnt = ProjectsUser.all.size
    kqp_cnt = KeyQuestionsProject.all.size
    efp_cnt = ExtractionFormsProject.all.size
    cp_cnt = CitationsProject.all.size
    ex_cnt = Extraction.all.size
    pt_cnt = ProjectsTag.all.size
    pr_cnt = ProjectsReason.all.size
    mdp_cnt = MeshDescriptorsProject.all.size

    # Just a sanity check to ensure we start with known counts of the :through associations.
    assert_equal(2, @original_project.key_questions.size)
    assert_equal(4, @original_project.citations.size)
    assert_equal(2, @original_project.tags.size)
    assert_equal(3, @original_project.reasons.size)
    assert_equal(3, @original_project.mesh_descriptors.size)
    assert_equal(5, @original_project.extractions.size)
    assert_equal(4, @original_project.extraction_forms_projects.size)

    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: false,
      include_labels: false
    }
    copied_project = ProjectCloningService.clone_project(@original_project, @leaders, opts)
    copied_project.destroy

    assert_equal(p_cnt, Project.all.size)
    assert_equal(cp_cnt, CitationsProject.all.size)
    assert_equal(pu_cnt, ProjectsUser.all.size)
    assert_equal(kqp_cnt, KeyQuestionsProject.all.size)
    assert_equal(pt_cnt, ProjectsTag.all.size)
    assert_equal(pr_cnt, ProjectsReason.all.size)
    assert_equal(mdp_cnt, MeshDescriptorsProject.all.size)
    assert_equal(ex_cnt, Extraction.all.size)
    assert_equal(efp_cnt, ExtractionFormsProject.all.size)
  end

  test 'copied citations_projects should belong to copied project' do
    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: false,
      include_labels: false
    }
    copied_project = ProjectCloningService.clone_project(@original_project, @leaders, opts)
    assert_equal(copied_project.citations_projects.size, 4)
    assert copied_project.citations_projects.include?(CitationsProject.unscoped.last), 'Last added CitationsProject should belong to project copy'
  end

  test "copied citations_projects should have screening_status 'asu'" do
    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: false,
      include_labels: false
    }
    copied_project = ProjectCloningService.clone_project(@original_project, @leaders, opts)
    copied_project.reload
    assert copied_project.citations_projects.all? { |cp| cp.screening_status.eql?('asu') },
      "All added CitationsProject should have 'asu' screening_status"
  end

  test "copied citations_projects should have screening_status 'eip' if extraction exists" do
    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: true,
      include_labels: false
    }
    copied_project = ProjectCloningService.clone_project(@original_project, @leaders, opts)
    copied_project.reload
    assert copied_project.citations_projects.all? { |cp| cp.screening_status.eql?('eip') },
      "All added CitationsProject should have 'eip' screening_status in the presence of extraction"
  end

  test "count of copied extractions should be the same as @original_project" do
    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: true,
      include_labels: false
    }
    copied_project = ProjectCloningService.clone_project(@original_project, @leaders, opts)

    assert_equal(copied_project.extractions.size, @original_project.extractions.size)
  end

  test "copied extractions should have same status as source" do
    opts = {
      include_citations: true,
      include_extraction_forms: true,
      include_extractions: true,
      include_labels: false
    }
    copied_project = ProjectCloningService.clone_project(@original_project, @leaders, opts)

    assert copied_project.extractions.any? { |ex| ex.status.eql?(Status.COMPLETED) }
    assert_equal(copied_project.extractions.map(&:citation), @original_project.extractions.map(&:citation))
    assert_equal(copied_project.extractions.map(&:status), @original_project.extractions.map(&:status))
  end
end
