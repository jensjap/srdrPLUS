require 'rails_helper'
require 'seed_data_helper'

RSpec.describe Degreeholdership, type: :model do
  before do
    extend SeedData
  end

  it 'should properly cache Degreeholdership objects referenced directly and also through Profile' do
    degreeholdership = @test_superadmin.degreeholderships.find_by(degree: Degree.find_by(name: 'MPH.'))
    user = degreeholdership.profile.user
    expect(degreeholdership.object_id).to eq(user.degreeholderships.last.object_id)
  end
end
