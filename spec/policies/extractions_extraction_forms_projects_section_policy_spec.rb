require 'rails_helper'

describe ExtractionsExtractionFormsProjectsSectionPolicy, type: :controller do
  let(:non_member) { FactoryBot.create(:user) }
  let(:leader) { FactoryBot.create(:user) }
  let(:consolidator) { FactoryBot.create(:user) }
  let(:contributor) { FactoryBot.create(:user) }
  let(:auditor) { FactoryBot.create(:user) }
  let(:project) do
    FactoryBot.create(:project).tap do |project|
      project.users << [leader, consolidator, contributor, auditor]
      ProjectsUser.where(project: project, user: leader).first
                  .roles << Role.where(name: 'Leader').first
      ProjectsUser.where(project: project, user: consolidator).first
                  .roles << Role.where(name: 'Consolidator').first
      ProjectsUser.where(project: project, user: contributor).first
                  .roles << Role.where(name: 'Contributor').first
      ProjectsUser.where(project: project, user: auditor).first
                  .roles << Role.where(name: 'Auditor').first
    end
  end

  before { sign_in user }

  subject { ExtractionsExtractionFormsProjectsSectionPolicy.new(user, project) }

  context 'for a non_member' do
    let(:user) { non_member }
    it { should_not permit(:update) }
  end

  context 'for leader' do
    let(:user) { leader }
    it { should permit(:update) }
  end

  context 'for consolidator' do
    let(:user) { consolidator }
    it { should permit(:update) }
  end

  context 'for contributor' do
    let(:user) { contributor }
    it { should permit(:update) }
  end

  context 'for auditor' do
    let(:user) { auditor }
    it { should_not permit(:update) }
  end
end
