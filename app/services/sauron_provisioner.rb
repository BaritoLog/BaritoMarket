class SauronProvisioner
  attr_accessor :sauron_host

  def initialize(sauron_host, opts = {})
    @sauron_host = sauron_host
    @image = opts[:image] || 'ubuntu:16.04'
  end

  def provision!(hostname, opts = {})
    create_res = create_container!(hostname, opts)
    return respond_error(create_res['errors']) unless create_res['success'] == 'true'

    # Get container details
    ipaddress = nil
    count = 0
    while ipaddress == nil || count == 30
      sleep(5) unless Rails.env.test?
      show_res = show_container(hostname)
      ipaddress = show_res.dig('data', 'ipaddress')
      count += 1
    end

    return {
      'success' => true,
      'data' => {
        'host_ipaddress' => ipaddress
      }
    }
  end

  def create_container!(hostname, opts = {})
    req = Typhoeus::Request.new(
      "#{@sauron_host}/containers",
      method: :post,
      body: {
        'container' => {
          'image' => @image,
          'container_hostname' => hostname
        }
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
    )
    req.run
    JSON.parse(req.response.body)
  end

  def show_container(hostname)
    req = Typhoeus::Request.new(
      "#{@sauron_host}/container.json",
      method: :get,
      params: {
        'container_hostname' => hostname,
      },
      headers: {
        'Content-Type' => 'application/json'
      }
    )
    req.run
    JSON.parse(req.response.body)
  end

  private
    def respond_error(error)
      { 'success' => false, 'error' => error }
    end
end
