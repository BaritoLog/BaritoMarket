class SauronProvisioner
  attr_accessor :sauron_host, :container_host, :container_host_name

  def initialize(sauron_host, container_host, container_host_name, opts = {})
    @sauron_host = sauron_host
    @container_host = container_host
    @container_host_name = container_host_name
    @image = opts[:image] || 'ubuntu:16.04'
  end

  def provision!(hostname, opts = {})
    create_res = create_container!(hostname, opts)
    return respond_error(create_res['errors']) unless create_res['success'] == 'true'

    # Give container time to initialize its networking
    # TODO: a better way to do this is to do a continuous poll until it returns ipaddress
    sleep(10) unless Rails.env.test?
    
    # Get container details
    show_res = show_container(hostname)

    return {
      'success' => true,
      'data' => {
        'host_ipaddress' => show_res.dig('data', 'ipaddress'),
        'key_pair_name' => create_res.dig('data', 'key_pair_name')
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
          'container_hostname' => hostname,
          'lxd_host_ipaddress' => @container_host,
          'key_pair_name' => opts[:key_pair_name]
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
        'lxd_host_ipaddress' => @container_host,
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
