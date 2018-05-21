class SauronProvisioner
  attr_accessor :sauron_host, :container_host, :container_host_name

  def initialize(sauron_host, container_host, container_host_name, opts = {})
    @sauron_host = sauron_host
    @container_host = container_host
    @container_host_name = container_host_name
    @image = opts[:image] || 'ubuntu:16.04'
  end

  def provision!(hostname, opts = {})
    req = Typhoeus::Request.new(
      "#{@sauron_host}/containers",
      method: :post,
      body: {
        'container' => {
          'image' => opts[:image] || @image,
          'container_hostname' => hostname,
          'lxd_host_ipaddress' => @container_host,
          'key_pair_name' => opts[:access_key_name],
        }
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      }
    )
    req.run
    res = req.response
    body = JSON.parse(res.body)

    if body['success'] == 'true'
      return {
        'success' => true,
        'data' => body['data']
      }
    else
      return {
        'success' => false,
        'error' => body['error']
      }
    end
  end
end
