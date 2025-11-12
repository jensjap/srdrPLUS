require 'rails_helper'

RSpec.describe UserSupplyingService, type: :service do
  let(:service) { UserSupplyingService.new }
  let(:user) { create(:user) }

  describe '#find_by_user_id' do
    it 'should return FHIR Practitioner' do
      result = service.find_by_user_id(user.id)

      expect(result['id'].split('-').last.to_i).to eq(user.id)
    end
  end
end
