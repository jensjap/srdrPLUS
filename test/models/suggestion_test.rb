require 'test_helper'

class SuggestionTest < ActiveSupport::TestCase
  def setup
    @suggestion = suggestions(:one)
    @degree = degrees(:one)
  end

  test 'should have suggestable' do
    assert_equal @suggestion.suggestable, @degree
  end
end
