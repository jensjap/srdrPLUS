require 'test_helper'

class DegreeProfileFlowTest < Capybara::Rails::TestCase
  def setup
  end

  test 'de-associating a degree should delete degreeholderships' do
    sign_in(@test_superadmin)

    visit edit_profile_path
    assert page.has_content?('Degree Information')
    # Find degrees that have a check marked.
    checked = page.all(:css, 'div.check_boxes.profile_degrees input[checked]')
    checked.map { |c| c.set(false) }

    # Compare number of degreeholderships.
    degreeholderships_before = Degreeholdership.count
    click_on 'Update Profile'
    degreeholderships_after = Degreeholdership.count
    assert_equal degreeholderships_before-degreeholderships_after, checked.count
  end

  test 'de-associating a degree should really delete degreeholderships' do
    sign_in(@test_superadmin)

    visit edit_profile_path
    assert page.has_content?('Degree Information')
    # Find degrees that have a check marked.
    checked = page.all(:css, 'div.check_boxes.profile_degrees input[checked]')
    checked.map { |c| c.set(false) }

    # Compare number of degreeholderships.
    degreeholderships_before_with_deleted = Degreeholdership.with_deleted.count
    click_on 'Update Profile'
    degreeholderships_after_with_deleted = Degreeholdership.with_deleted.count
    assert_equal degreeholderships_before_with_deleted - degreeholderships_after_with_deleted, checked.count
  end
end
