class SauronProvisioner
  attr_accessor :sauron_host

  def initialize(sauron_host, opts = {})
    @sauron_host = sauron_host
    @image = opts[:image] || 'ubuntu:16.04'
  end

  def provision!(hostname)
    create_res = create_container!(hostname)
    return respond_error(create_res['errors']) unless create_res['success'] == 'true'
    return create_res
  end

  def create_container!(hostname)
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
