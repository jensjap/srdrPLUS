require 'test_helper'

class ProjectCloningServiceTest < ActiveSupport::TestCase
  setup do
    @original_project = projects(:copy_project_original)
    @user1 = users(:one)
    @user2 = users(:two)
  end

  test 'cloning project should create the correct number of new records' do
    p_cnt = Project.all.size
    pu_cnt = ProjectsUser.all.size
    kqp_cnt = KeyQuestionsProject.all.size
    efp_cnt = ExtractionFormsProject.all.size
    cp_cnt = CitationsProject.all.size
    ex_cnt = Extraction.all.size

    ProjectCloningService.clone_project(@original_project, leaders: [@user1, @user2])

    assert_equal(p_cnt + 1, Project.all.size)
    assert_equal(pu_cnt + 2, ProjectsUser.all.size)
    assert_equal(kqp_cnt + KeyQuestionsProject.where(project: @original_project).size, KeyQuestionsProject.all.size)
    assert_equal(efp_cnt + ExtractionFormsProject.where(project: @original_project).size, ExtractionFormsProject.all.size)
    assert_equal(cp_cnt + CitationsProject.where(project: @original_project).size, CitationsProject.all.size)
    assert_equal(ex_cnt, Extraction.all.size)
    assert_equal(2, @original_project.key_questions.size)
    assert_equal(4, @original_project.extraction_forms_projects.size)
    assert_equal(4, @original_project.citations.size)
    assert_equal(5, @original_project.extractions.size)
  end

  test 'cloning project with extractions should create new extraction records' do
    ex_cnt = Extraction.all.size

    ProjectCloningService.clone_project(@original_project, copy_extractions: true, leaders: [@user1, @user2])

    assert_equal(ex_cnt + Extraction.where(project: @original_project).size, Extraction.all.size)
  end
end
