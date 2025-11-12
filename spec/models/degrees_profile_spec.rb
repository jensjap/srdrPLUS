require 'rails_helper'

RSpec.describe DegreesProfile, type: :model do
  let(:degree) { create(:degree) }
  let(:user) { create(:user) }
  let(:profile) { user.profile }

  describe 'validations' do
    it 'without degree should be invalid' do
      degrees_profile = DegreesProfile.new(degree: nil, profile: profile)
      expect(degrees_profile).not_to be_valid
    end

    it 'without profile should be invalid' do
      degrees_profile = DegreesProfile.new(degree: degree, profile: nil)
      expect(degrees_profile).not_to be_valid
    end

    it 'with degree and profile should be valid' do
      degrees_profile = DegreesProfile.new(degree: degree, profile: profile)
      expect(degrees_profile).to be_valid
    end
  end
end
