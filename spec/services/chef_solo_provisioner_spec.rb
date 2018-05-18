require 'rails_helper'

RSpec.describe ChefSoloProvisioner do
  before(:each) do
  end

  describe '#process!' do
    it 'should create node json attributes file' do
      # Don't actually run knife solo
      status = double('status')
      allow(status).to receive(:success?).and_return(true)
      allow(Open3).to receive(:capture3).and_return([Object.new, '', status])

      # Create tmp directory if not exist
      FileUtils.mkdir_p "#{Rails.root}/tmp/chef/nodes"

      provisioner = ChefSoloProvisioner.new("#{Rails.root}/tmp/chef")
      provisioner.provision!('localhost', 'user', attrs: @test_attributes)
      expect(File).to exist("#{Rails.root}/tmp/chef/nodes/localhost.json")
    end
  end
end
