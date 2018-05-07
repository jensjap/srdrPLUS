require 'test_helper'

class DegreeProfileFlowTest < Capybara::Rails::TestCase

  def setup
    sign_in(users(:one))
    visit edit_profile_path
  end

  test 'de-associating a degree should delete degrees_profiles' do
    assert page.has_content? 'Degree Information'

    # Find degrees that have a check marked.
    checked = page.all(:css, 'li.select2-selection__choice')
    checked.each do |choice|
      choice.find(:css,  'span.select2-selection__choice__remove').click
    end

    # Compare number of degrees_profiles.
    assert_difference('DegreesProfile.count', -checked.count) do
      click_on 'Update Profile'
    end
  end
end
