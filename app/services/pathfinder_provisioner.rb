class PathfinderProvisioner
  attr_accessor :pathfinder_host, :pathfinder_cluster

  def initialize(pathfinder_host,
    pathfinder_token,
    pathfinder_cluster,
    opts = {}
  )

    @pathfinder_host = pathfinder_host
    @pathfinder_token = pathfinder_token
    @pathfinder_cluster = pathfinder_cluster
    @image = opts[:image] || '16.04'
  end

  def provision!(hostname)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v1/ext_app/containers.json",
      method: :post,
      params: {
        'cluster_name' => @pathfinder_cluster,
      },
      body: {
        'container' => {
          'hostname' => hostname,
          'image' => @image
        }
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )
    req.run

    if req.response.success?
      return respond_success(req.response)
    else
      return respond_error(req.response)
    end
  end

  def show_container(hostname)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v1/ext_app/containers/#{hostname}",
      method: :get,
      params: {
        'cluster_name' => @pathfinder_cluster,
      },
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )
    req.run
    return respond_success(req.response)
  end

  def reprovision!(hostname)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v1/ext_app/containers/#{hostname}/reschedule",
      method: :post,
      params: {
        'cluster_name' => @pathfinder_cluster,
      },
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )
    req.run

    if req.response.success?
      return respond_success(req.response)
    else
      return respond_error(req.response)
    end
  end

  private
    def respond_success(response)
      body = JSON.parse(response.body)
      {
        'success' => true,
        'data' => {
          'ipaddress' => body.dig('data', 'ipaddress')
        }
      }
    end

    def respond_error(response)
      body = JSON.parse(response.body)
      { 'success' => false, 'error' => body.dig('error', 'message') }
    end
end
