require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = projects(:two)
    @publishing = publishings(:one)
    @user = users(:two)
    @key_question = key_questions(:one)
  end

  test 'ensure project has publishing requests ' do
    refute_equal @project.publishings.count, 0
  end

  test 'project responds to publishings' do
    assert @project.respond_to?(:publishings)
  end

  test 'publishings can created for project' do
    previous_publishings_cnt = @project.publishings.count
    @project.publishings << Publishing.create(publishable: @project, user: @user)
    assert @project.publishings, previous_publishings_cnt + 1
  end

  test 'requesting publishing should create it with correct requested_by' do
    project_without_publishings = Project.where.not(id: Project.includes(:publishings).\
                                                    joins(:publishings).\
                                                    where('publishings.user_id IS NOT NULL').\
                                                    pluck(:id)).first
    assert project_without_publishings.publishings.blank?
    project_without_publishings.request_publishing
    refute project_without_publishings.publishings.blank?
  end

  test 'attempting to request publishing by the same user should not work' do
    project_without_publishings = Project.where.not(id: Project.includes(:publishings).\
                                                    joins(:publishings).\
                                                    where('publishings.user_id IS NOT NULL').\
                                                    pluck(:id)).first
    assert project_without_publishings.publishings.blank?
    project_without_publishings.request_publishing
    refute project_without_publishings.publishings.blank?
    assert_raises(ActiveRecord::RecordNotUnique) { project_without_publishings.request_publishing }
  end

  test 'requesting publishing by specific user' do
    project = Project.create(name: 'New Project')
    project.request_publishing_by(@user)
    refute_nil project.publishings
    assert_equal project.publishings.first.user, @user
  end

  test 'accepts nested fields' do
    assert_difference 'KeyQuestionsProject.count', 1 do
      @project.update({ "key_questions_projects_attributes"=>{ "1493942830398"=>{ "_destroy"=>"false", "key_question_attributes"=>{ "name"=>@key_question.name } } } } )
    end
  end

  test 'submitting known key question should not create new one' do
    assert_no_difference 'KeyQuestion.count' do
      @project.update({ "key_questions_projects_attributes"=>{ "1493942830398"=>{ "_destroy"=>"false", "key_question_attributes"=>{ "name"=>@key_question.name } } } } )
    end
  end

  test 'submitting unknown key question should create new one' do
    assert_difference 'KeyQuestion.count', 1 do
      @project.update({ "key_questions_projects_attributes"=>{ "1493942830398"=>{ "_destroy"=>"false", "key_question_attributes"=>{ "name"=>'kq1'} } } } )
    end
  end
end
