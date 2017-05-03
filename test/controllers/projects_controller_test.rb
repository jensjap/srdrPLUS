require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @project = projects(:one)
    @key_questions_projects1 = key_questions_projects(:one)
    @key_questions_projects2 = key_questions_projects(:two)
    @kq1 = key_questions(:one)
    @kq2 = key_questions(:two)
  end

  test 'should get index' do
    get projects_url
    assert_response :success
  end

  test 'should get new' do
    get new_project_url
    assert_response :success
  end

  test 'should create project' do
    assert_difference('Project.count') do
      post projects_url, params: { project: { attribution: @project.attribution, description: @project.description, doi: @project.doi, funding_source: @project.funding_source, methodology_description: @project.methodology_description, name: 'new project', notes: @project.notes, prospero: @project.prospero } }
    end

    assert_redirected_to edit_project_url(Project.last)
  end

  test 'should show project' do
    get project_url(@project)
    assert_response :success
  end

  test 'should get edit' do
    get edit_project_url(@project)
    assert_response :success
  end

  test 'should update project' do
    patch project_url(@project), params: { project: { attribution: @project.attribution, description: @project.description, doi: @project.doi, funding_source: @project.funding_source, methodology_description: @project.methodology_description, name: @project.name, notes: @project.notes, prospero: @project.prospero } }
    assert_redirected_to project_url(@project)
  end

  test 'should destroy project' do
    assert_difference('Project.count', -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  test 'should create key question association' do
    assert_difference('KeyQuestionsProject.count', 1) do
      patch project_url(@project), params: { project: { attribution: @project.attribution, description: @project.description, doi: @project.doi, funding_source: @project.funding_source, methodology_description: @project.methodology_description, name: @project.name, notes: @project.notes, prospero: @project.prospero,
                                                        key_questions_projects_attributes: { '0': { key_question_attributes: { name: @kq1.name } } } } }
    end
  end

  test 'should not create new key question' do
    assert_difference('KeyQuestion.count', 0) do
      patch project_url(@project), params: { project: { attribution: @project.attribution, description: @project.description, doi: @project.doi, funding_source: @project.funding_source, methodology_description: @project.methodology_description, name: @project.name, notes: @project.notes, prospero: @project.prospero,
                                                        key_questions_projects_attributes: { '0': { key_question_attributes: { name: @kq2.name } } } } }
    end
  end

  test 'should not create new key_questions_project' do
    assert_difference('KeyQuestionsProject.count', 0) do
      patch project_url(@project), params: { project: { attribution: @project.attribution, description: @project.description, doi: @project.doi, funding_source: @project.funding_source, methodology_description: @project.methodology_description, name: @project.name, notes: @project.notes, prospero: @project.prospero,
                                                        key_questions_projects_attributes: { '0': { key_question_attributes: { name: @kq2.name } }, id: @key_questions_projects1.id } } }
    end
  end
end
