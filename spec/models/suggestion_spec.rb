require 'rails_helper'

RSpec.describe Suggestion, type: :model do
  let(:suggestable) { create(:degree) }
  let(:user) { create(:user) }

  before(:each) do
    # Set User.current to a valid user to handle after_create callbacks
    User.current = create(:user)
  end

  after(:each) do
    User.current = nil
  end

  describe 'validations' do
    it 'without suggestable should be invalid' do
      suggestion = Suggestion.new(suggestable: nil, user: user)
      expect(suggestion).not_to be_valid
    end

    it 'without user should be invalid' do
      suggestion = Suggestion.new(suggestable: suggestable, user: nil)
      expect(suggestion).not_to be_valid
    end

    it 'with suggestable and user should be valid' do
      suggestion = Suggestion.new(suggestable: suggestable, user: user)
      expect(suggestion).to be_valid
    end
  end
end
