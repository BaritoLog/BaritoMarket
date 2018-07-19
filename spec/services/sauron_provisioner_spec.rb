require 'rails_helper'

RSpec.describe SauronProvisioner do
  describe '#provision!' do
    before(:all) do
      @sauron_host = '127.0.0.1:3000'

      # Mock Sauron API
      stub_request(:post, "http://#{@sauron_host}/containers").
        with(
          body: {
            'container' => {
              'image' => 'ubuntu:16.04',
              'container_hostname' => 'test-01',
            }
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Expect' => '',
            'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
          }
        ).to_return({
          status: 200,
          headers: {
            'Content-Type' => 'application/json',
            'Expect' => '',
            'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
          },
          body: {
            'success' => 'true',
            'error' => '',
            'data' => {
            }
          }.to_json
        })
    end

    context 'using SauronProvisioner' do
      it 'should make necessary calls to Sauron and return the response' do
        sauron_provisioner = SauronProvisioner.new(
          @sauron_host)
        provision_result = sauron_provisioner.
          provision!('test-01')
        expect(provision_result).to eq({
          'success' => 'true',
          'error' => '',
          'data' => {
          }
        })
      end
    end
  end
end
