require 'rails_helper'
require 'seed_data_helper'

RSpec.describe Profile, type: :model do
  before do
    extend SeedData
  end

  it 'should return number of degrees' do
    degrees = @superadmin_profile.degrees
    expect(degrees.count).to eq(3)
  end

  it 'profile without organization should be valid' do
    @superadmin_profile.organization = nil
    expect(@superadmin_profile).to be_valid(@superadmin_profile)
  end
end
