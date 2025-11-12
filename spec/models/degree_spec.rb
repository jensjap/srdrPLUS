require 'rails_helper'

RSpec.describe Degree, type: :model do
  let(:degree) { create(:degree) }

  before(:each) do
    # Set User.current to a valid user to handle after_create callbacks
    User.current = create(:user)
  end

  after(:each) do
    User.current = nil
  end

  it 'should properly cache Degree objects referenced directly, and also through degrees_profiles' do
    degrees_profile = degree.degrees_profiles.first
    expect(degree.object_id).to eq(degrees_profile.degree.object_id) if degrees_profile
  end

  it 'no new degree should be added when creating with same name' do
    existing_degree = create(:degree)
    previous_degree_cnt = Degree.count
    Degree.create(name: existing_degree.name)
    expect(Degree.count).to eq(previous_degree_cnt)
  end

  it 'degree with same name should be invalid' do
    existing_degree = create(:degree)
    new_degree = Degree.new(name: existing_degree.name)
    expect(new_degree).not_to be_valid
  end

  it 'deleting degree should raise' do
    degree_to_delete = create(:degree)
    expect { degree_to_delete.destroy }.to raise_error(RuntimeError, 'You should NEVER delete a Degree.')
  end
end
