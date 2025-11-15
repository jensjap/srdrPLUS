require 'rails_helper'

RSpec.describe Organization, type: :model do
  let(:organization_one) { create(:organization) }
  let(:organization_two) { create(:organization) }

  before(:each) do
    # Set User.current to a valid user to handle after_create callbacks
    User.current = create(:user)
  end

  after(:each) do
    User.current = nil
  end

  describe '#by_query' do
    it 'should return organizations matching the query' do
      # Ensure we have 2 organizations created
      organization_one
      organization_two
      results = Organization.by_query('org')
      # Filter to only Organization objects (by_query may add OpenStruct entries)
      org_results = results.select { |r| r.is_a?(Organization) }
      # Should return both organizations
      expect(org_results.count).to be >= 2
      expect(org_results).to include(organization_one)
      expect(org_results).to include(organization_two)
    end
  end

  describe '#process_token' do
    let(:user) { create(:user) }
    let(:profile) { user.profile }

    before do
      User.current = profile.user
    end

    it 'should create resource and suggestion by user' do
      previous_suggestion_cnt = Suggestion.count
      previous_organization_cnt = Organization.count
      profile.send(:save_resource_name_with_token, Organization.new, '<<<aaa>>>')
      expect(Organization.count).to eq(previous_organization_cnt + 1)
      expect(Suggestion.count).to eq(previous_suggestion_cnt + 1)
      expect(Suggestion.last.user).to eq(User.current)
    end

    it 'should not create resource and suggestion by user with invalid token (\'0\')' do
      previous_suggestion_cnt = Suggestion.count
      previous_organization_cnt = Organization.count
      profile.send(:save_resource_name_with_token, Organization.new, '0')
      expect(Organization.count).to eq(previous_organization_cnt)
      expect(Suggestion.count).to eq(previous_suggestion_cnt)
    end

    it 'should not create resource and suggestion by user with invalid token (\'aaa\')' do
      previous_suggestion_cnt = Suggestion.count
      previous_organization_cnt = Organization.count
      profile.send(:save_resource_name_with_token, Organization.new, 'aaa')
      expect(Organization.count).to eq(previous_organization_cnt)
      expect(Suggestion.count).to eq(previous_suggestion_cnt)
    end
  end

  describe 'uniqueness validation' do
    it 'no new organization should be added when creating with same name' do
      existing_org = create(:organization)
      previous_organization_cnt = Organization.count
      Organization.create(name: existing_org.name)
      expect(Organization.count).to eq(previous_organization_cnt)
    end

    it 'organization with same name should be invalid' do
      existing_org = create(:organization)
      new_org = Organization.new(name: existing_org.name)
      expect(new_org).not_to be_valid
    end
  end
end
