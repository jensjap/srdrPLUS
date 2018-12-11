require 'rails_helper'

describe ExtractionPolicy, type: :controller do
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

  subject { ExtractionPolicy.new(user, project) }

  context 'for a non_member' do
    let(:user) { non_member }
    it { should_not permit(:new) }
    it { should_not permit(:edit) }
    it { should_not permit(:create) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }
    it { should_not permit(:work) }
    it { should_not permit(:comparison_tool) }
    it { should_not permit(:consolidate) }
    it { should_not permit(:edit_type1_across_extractions) }
  end

  context 'for leader' do
    let(:user) { leader }
    it { should permit(:new) }
    it { should permit(:edit) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should permit(:destroy) }
    it { should permit(:work) }
    it { should permit(:comparison_tool) }
    it { should permit(:consolidate) }
    it { should permit(:edit_type1_across_extractions) }
  end

  context 'for consolidator' do
    let(:user) { consolidator }
    it { should permit(:new) }
    it { should permit(:edit) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should_not permit(:destroy) }
    it { should permit(:work) }
    it { should permit(:comparison_tool) }
    it { should permit(:consolidate) }
    it { should permit(:edit_type1_across_extractions) }
  end

  context 'for contributor' do
    let(:user) { contributor }
    it { should permit(:new) }
    it { should permit(:edit) }
    it { should permit(:create) }
    it { should permit(:update) }
    it { should_not permit(:destroy) }
    it { should permit(:work) }
    it { should_not permit(:comparison_tool) }
    it { should_not permit(:consolidate) }
    it { should_not permit(:edit_type1_across_extractions) }
  end

  context 'for auditor' do
    let(:user) { auditor }
    it { should permit(:new) }
    it { should_not permit(:edit) }
    it { should_not permit(:create) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }
    it { should_not permit(:work) }
    it { should_not permit(:comparison_tool) }
    it { should_not permit(:consolidate) }
    it { should_not permit(:edit_type1_across_extractions) }
  end
end
