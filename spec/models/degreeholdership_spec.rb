require 'rails_helper'
require 'seed_data_helper'

RSpec.describe Degreeholdership, type: :model do
  before do
    extend SeedData
  end

  it 'should properly cache Degreeholdership objects referenced directly and also through Profile' do
    degreeholdership = @superadmin_profile.degreeholderships.first
    expect(degreeholdership.profile.object_id).to eq(@superadmin_profile.object_id)
  end
end
