require 'test_helper'

class KeyQuestionProjectFlowTest < Capybara::Rails::TestCase
  def setup
    sign_in(users(:one))
    visit edit_project_path(projects(:one))
  end

  test 'adding key question should create key_questions_projects' do
    assert page.has_content? 'Create Key Question'
    
    page.find(:css, '#key_questions_project_key_question_attributes_name').set('loyloy')

    assert_difference('KeyQuestionsProject.count', 1) do  
      click_on 'Save Key Question'
    end
  end
end

