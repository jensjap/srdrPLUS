require 'test_helper'

class DependencyFlowTest < Capybara::Rails::TestCase
  def setup
    sign_in(users(:one))
    visit build_extraction_forms_project_path(extraction_forms_projects(:one))

    page.click_on 'Add Question'
    page.find('.question_name').set('loyloy')
    page.click_on 'Next: Define the question type and answer choices'
    page.click_on 'Save Question Type Details and Close'

    page.click_on 'Add Question'
    page.find('.question_name').set('leyley')
    page.click_on 'Next: Define the question type and answer choices'
    page.click_on 'Save Question Type Details and Close'

    page.click_on "Dependencies"
    page.click_on "Prerequisite"
    page.click_on "Save and Finalize"
  end

  test 'build EFPS must load after creating dependency' do
    assert page.has_content?
  end
end

