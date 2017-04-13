require 'test_helper'

class SuggestionTest < ActiveSupport::TestCase
  def setup
    @suggestion = suggestions(:one)
    @suggestable = degrees(:one)
    @user = users(:one)
  end

  test 'without suggestable should be invalid' do
    refute Suggestion.new(suggestable: nil, user: @user).valid?
  end

  test 'without user should be invalid' do
    refute Suggestion.new(suggestable: @suggestable, user: nil).valid?
  end

  test 'with suggestable and user should be valid' do
    assert Suggestion.new(suggestable: @suggestable, user: @user).valid?
  end
end
