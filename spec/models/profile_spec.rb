require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:user_one) { create(:user) }
  let(:user_two) { create(:user) }
  let(:organization_one) { create(:organization) }
  let(:organization_two) { create(:organization) }
  # Users automatically get a profile created via after_create callback
  let(:profile_one) { user_one.profile.tap { |p| p.update(organization: organization_one) } }
  let(:profile_two) { user_two.profile }

  before(:each) do
    # Set User.current to a valid user to handle after_create callbacks
    User.current = create(:user)
  end

  after(:each) do
    User.current = nil
  end

  describe 'degree association' do
    it 'submitting properly formatted degree_ids should update correctly' do
      # Create 5 degrees first
      5.times { create(:degree) }
      degree_ids = Degree.first(5).pluck(:id).map(&:to_s) << "<<<aaa>>>"
      params = { degree_ids: degree_ids }
      profile_one.update(params)
      expect(profile_one.degrees.count).to eq(6)
      expect(profile_one.degrees.where(name: 'aaa').first).to eq(Degree.last)
    end
  end

  describe 'organization association' do
    it 'submitting properly formatted organization_id tokens should associate profile with organization' do
      params = { organization_id: organization_two.id.to_s }
      expect(profile_one.organization).not_to be_nil
      profile_one.update(params)
      expect(profile_one.organization).to eq(organization_two)
    end

    it 'should properly cache Profile objects referenced directly, and also through degrees_profiles' do
      # Create a degree and associate it with the profile first
      degree = create(:degree)
      profile_one.degrees << degree
      degrees_profile = profile_one.degrees_profiles.first
      expect(profile_one.object_id).to eq(degrees_profile.profile.object_id)
    end

    it 'submitting properly formatted organization_id tokens (\'<<<0>>>\') should associate profile with newly created organization' do
      params = { organization_id: '<<<0>>>' }
      profile_one.update(params)
      expect(profile_one.organization).not_to eq(organization_one)
      expect(profile_one.organization.name).to eq('0')
    end

    it 'submitting properly formatted organization_id tokens should associate profile with newly created organization' do
      params = { organization_id: '<<<loyloyloy>>>' }
      previous_organization = profile_one.organization
      expect(previous_organization).not_to be_nil
      profile_one.update(params)
      current_organization = Organization.last
      expect(profile_one.organization).to eq(current_organization)
      expect(previous_organization).not_to eq(current_organization)
    end

    it 'submitting properly formatted organization_id tokens should de-associate profile from organization' do
      params = { organization_id: '<<<loyloyloy>>>' }
      expect(profile_one.organization).not_to be_nil
      profile_one.update(params)
      expect(profile_one.organization).to eq(Organization.last)
    end

    it 'submitting malformed organization_id tokens should raise' do
      params = { organization_id: 'loyloyloy' }
      expect(profile_one.organization).not_to be_nil
      expect { profile_one.update(params) }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it 'submitting malformed organization_id tokens (0 string) should raise' do
      params = { organization_id: '0' }
      expect(profile_one.organization).not_to be_nil
      expect { profile_one.update(params) }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end

  describe 'username validation' do
    it 'username should not have spaces' do
      profile_one.username = 'super cool username'
      expect(profile_one).not_to be_valid
    end

    it 'username cannot be another person\'s email' do
      profile_one.username = user_two.email
      expect(profile_one).not_to be_valid
      expect(profile_one.errors.messages[:username]).to eq(['is invalid', 'Username already taken!'])
    end

    it 'username with \'@\' symbol should be invalid' do
      profile_one.username = 'something@something'
      expect(profile_one).not_to be_valid
      expect(profile_one.errors.messages[:username]).to eq(['is invalid'])
    end
  end

  describe 'user uniqueness' do
    it 'profile with same user should not save' do
      profile_one.user = user_one
      profile_two.user = user_one

      profile_one.save
      expect(profile_two.save).to be false
    end
  end
end
