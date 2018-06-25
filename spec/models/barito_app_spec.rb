require 'rails_helper'

RSpec.describe BaritoApp, type: :model do
  context 'Status Update' do
    let(:barito_app) { create(:barito_app) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = barito_app.update_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update barito_app status' do
      status = BaritoApp.statuses.keys.sample
      status_update = barito_app.update_status(status)
      expect(status_update).to eq(true)
      expect(barito_app.status.downcase).to eq(status)
    end
  end

  context 'It should validate secret key' do
    let(:barito_app) { create(:barito_app) }
    it 'should return true for a valid key' do
      expect(BaritoApp.secret_key_valid?(barito_app.secret_key)).
        to eq(true)
    end
    it 'should return false for an invalid key' do
      expect(BaritoApp.secret_key_valid?(SecureRandom.base64)).
        not_to eq(true)
    end
  end

  context 'It should generate secret_key' do
    it 'should generate uuid without \'-\'' do
      key = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid).and_return(key)
      expect(BaritoApp.generate_key).to eq(key.gsub('-', ''))
    end
  end
end
