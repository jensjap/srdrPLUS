require 'rails_helper'

RSpec.describe Approval, type: :model do
  let(:user) { create(:user) }
  let(:approvable) { create(:project) } # Using project as approvable polymorphic association

  describe 'validations' do
    it 'without approvable should be invalid' do
      approval = Approval.new(approvable: nil, user: user)
      expect(approval).not_to be_valid
    end

    it 'without user should be invalid' do
      approval = Approval.new(approvable: approvable, user: nil)
      expect(approval).not_to be_valid
    end

    it 'with user and approvable should be valid' do
      approval = Approval.new(approvable: approvable, user: user)
      expect(approval).to be_valid
    end
  end
end
