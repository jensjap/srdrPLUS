require 'rails_helper'

describe ProjectPolicy, type: :controller do
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

  subject { ProjectPolicy.new(user, project) }

  context 'for a non_member' do
    let(:user) { non_member }
    it { should_not permit(:edit) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }
    it { should_not permit(:export) }
    it { should_not permit(:import_csv) }
    it { should_not permit(:import_pubmed) }
    it { should_not permit(:import_ris) }
    it { should_not permit(:import_endnote) }
    it { should_not permit(:next_assignment) }
  end

  context 'for leader' do
    let(:user) { leader }
    it { should permit(:edit) }
    it { should permit(:update) }
    it { should permit(:destroy) }
    it { should permit(:export) }
    it { should permit(:import_csv) }
    it { should permit(:import_pubmed) }
    it { should permit(:import_ris) }
    it { should permit(:import_endnote) }
    it { should permit(:next_assignment) }
  end

  context 'for consolidator' do
    let(:user) { consolidator }
    it { should_not permit(:edit) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }
    it { should permit(:export) }
    it { should_not permit(:import_csv) }
    it { should_not permit(:import_pubmed) }
    it { should_not permit(:import_ris) }
    it { should_not permit(:import_endnote) }
    it { should permit(:next_assignment) }
  end

  context 'for contributor' do
    let(:user) { contributor }
    it { should_not permit(:edit) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }
    it { should permit(:export) }
    it { should_not permit(:import_csv) }
    it { should_not permit(:import_pubmed) }
    it { should_not permit(:import_ris) }
    it { should_not permit(:import_endnote) }
    it { should permit(:next_assignment) }
  end

  context 'for auditor' do
    let(:user) { auditor }
    it { should_not permit(:edit) }
    it { should_not permit(:update) }
    it { should_not permit(:destroy) }
    it { should_not permit(:export) }
    it { should_not permit(:import_csv) }
    it { should_not permit(:import_pubmed) }
    it { should_not permit(:import_ris) }
    it { should_not permit(:import_endnote) }
    it { should_not permit(:next_assignment) }
  end
end
