require 'rails_helper'

RSpec.describe Publishing, type: :model do
  let(:user) { create(:user) }
  let(:publishing_with_approval) { create(:publishing, user: user) }
  let(:publishing_without_approval) { create(:publishing, user: user) }

  describe 'approval status' do
    it 'requested publishing request is not approved' do
      expect(publishing_without_approval.approval).to be_blank
      expect(publishing_without_approval.approved?).to be false
    end

    it 'approving publishing request is approved' do
      expect(publishing_without_approval.approved?).to be false
      publishing_without_approval.approve_by(user)
      expect(publishing_without_approval.approved?).to be true
    end
  end
end
