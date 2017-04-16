require 'test_helper'

class DegreeProfileFlowTest < Capybara::Rails::TestCase
  def setup
    sign_in(users(:one))
    visit edit_profile_path
  end

  test 'de-associating a degree should delete degrees_profiles' do
    assert page.has_content? 'Degree Information'

    # Find degrees that have a check marked.
    checked = page.all(:css, 'div.check_boxes.profile_degrees input[checked]')
    checked.map { |c| c.set(false) }

    # Compare number of degrees_profiles.
    degrees_profiles_before = DegreesProfile.count
    click_on 'Update Profile'
    degrees_profiles_after = DegreesProfile.count
    assert_equal degrees_profiles_before-degrees_profiles_after, checked.count
  end

  test 'de-associating a degree should delete degrees_profiles (redux)' do
    assert page.has_content? 'Degree Information'

    # Find degrees that have a check marked.
    checked = page.all(:css, 'div.check_boxes.profile_degrees input[checked]')
    checked.map { |c| c.set(false) }

    # Compare number of degrees_profiles.
    assert_difference('DegreesProfile.count', -checked.count) do
      click_on 'Update Profile'
    end
  end

  test 'de-associating a degree should really delete degrees_profiles' do
    assert page.has_content? 'Degree Information'

    # Find degrees that have a check marked.
    checked = page.all(:css, 'div.check_boxes.profile_degrees input[checked]')
    checked.map { |c| c.set(false) }

    # Compare number of degrees_profiles.
    degrees_profiles_before_with_deleted = DegreesProfile.with_deleted.count
    click_on 'Update Profile'
    degrees_profiles_after_with_deleted = DegreesProfile.with_deleted.count
    assert_equal degrees_profiles_before_with_deleted - degrees_profiles_after_with_deleted, checked.count
  end
end
