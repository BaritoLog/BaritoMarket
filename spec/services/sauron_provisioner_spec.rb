require 'rails_helper'

RSpec.describe SauronProvisioner do
  describe '#provision!' do
    before(:all) do
      @sauron_host = '127.0.0.1:3000'
      @container_host = '127.0.0.1'
      @container_host_name = 'localhost'
      @access_key = 'barito'

      # Mock Sauron API
      stub_request(:post, "http://#{@sauron_host}/containers").
        with(
          body: {
            'container' => {
              'image' => 'ubuntu:16.04',
              'container_hostname' => 'test-01',
              'lxd_host_ipaddress' => @container_host,
              'access_key' => 'barito'
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
              'ip_address' => 'xx.yy.zz.hh',
              'access_key' => 'barito'
            }
          }.to_json
        })
    end

    context 'using SauronProvisioner' do
      it 'should make necessary calls to Sauron and return the response' do
        sauron_provisioner = SauronProvisioner.new(
          @sauron_host, @container_host, @container_host_name)
        expect(sauron_provisioner.provision!('test-01', access_key: @access_key)).to eq({
          'success' => true,
          'data' => {
            'ip_address' => 'xx.yy.zz.hh',
            'access_key' => 'barito'
          }
        })
      end
    end
  end
end
