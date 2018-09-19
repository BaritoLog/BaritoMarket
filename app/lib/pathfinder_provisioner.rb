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
    @image = opts[:image] || '18.04'
  end

  def provision!(hostname)
    request = Typhoeus::Request.new(
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

    do_request(request)
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
    request = Typhoeus::Request.new(
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
    do_request(request)
  end

  def delete_container!(hostname)
    request = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v1/ext_app/containers/#{hostname}/schedule_deletion",
      method: :post,
      params: {
        'cluster_name' => @pathfinder_cluster,
      },
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )

    request.run

    if request.response.success?
      body = JSON.parse(request.response.body)
      {
          'success' => true,
          'data' => body
      }
    elsif request.response.timed_out?
      return respond_error_message("Provisioner time out")
    elsif request.response.code == 0
      return respond_error_message(request.response.return_message)
    else
      return respond_error(request.response)
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
      error_message = ""
      begin
        body = JSON.parse(response.body)
        error_message = body.dig('error', 'message')
      rescue JSON::ParserError => ex
        error_message = ex.to_s
      end
      respond_error_message(error_message)
    end

    def respond_error_message(error_message)
      { 'success' => false, 'error' => error_message}
    end

    def do_request(request)
      request.on_complete do |response|
        if response.success?
          return respond_success(response)
        elsif response.timed_out?
          return respond_error_message("Provisioner time out")
        elsif response.code == 0
          return respond_error_message(response.return_message)
        else
          return respond_error(response)
        end
      end

      request.run
    end
end
