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
  end

  def provision!(hostname, source, bootstrappers)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v2/ext_app/containers.json",
      method: :post,
      params: {
        'cluster_name' => @pathfinder_cluster,
      },
      body: {
        'container' => {
          'hostname' => hostname,
          'source' => source,
          'bootstrappers' => bootstrappers
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
      "#{@pathfinder_host}/api/v2/ext_app/containers/#{hostname}",
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

  def reprovision!(hostname, source, bootstrappers)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v2/ext_app/containers/#{hostname}/reschedule",
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
    elsif req.response.response_code == 404
      provision!(hostname, source, bootstrappers)
    else
      return respond_error(req.response)
    end
  end

  def delete_container!(hostname)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v2/ext_app/containers/#{hostname}/schedule_deletion",
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
      body = JSON.parse(req.response.body)
      {
        'success' => true,
        'data' => body['data']
      }
    else
      return respond_error(req.response)
    end
  end

  def rebootstrap!(hostname, bootstrappers)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v2/ext_app/containers/#{hostname}/rebootstrap",
      method: :post,
      params: {
        'cluster_name' => @pathfinder_cluster
      },
      body: {
        'bootstrappers' => bootstrappers
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )
    req.run

    if req.response.success?
      body = JSON.parse(req.response.body)
      {
        'success' => true,
        'data' => body['data']
      }
    else
      return respond_error(req.response)
    end
  end

  def bulk_apply!(deployments)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v2/ext_app/deployments/bulk_apply",
      method: :post,
      body: {
        'deployments' => deployments
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )
    req.run
    if req.response.success?
      body = JSON.parse(req.response.body)
      {
        'success' => true
      }
    else
      return respond_error(req.response)
    end
  end

  def list_containers!(deployment_name)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v2/ext_app/deployments/list_containers",
      method: :get,
      params: {
        'name' => deployment_name,
      },
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )
    req.run
    if req.response.success?
      body = JSON.parse(req.response.body)
      {
        'success' => true,
        'data' => body['data']
      }
    else
      return []
    end
  end

  def update_container!(component)
    req = Typhoeus::Request.new(
      "#{@pathfinder_host}/api/v2/ext_app/containers/#{component.hostname}/update",
      method: :post,
      params: {
        'cluster_name' => @pathfinder_cluster
      },
      body: {
        'hostname' => component.hostname,
        'bootstrappers' => component.bootstrappers,
        'source' => component.source
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Auth-Token' => @pathfinder_token
      }
    )
    req.run
    if req.response.success?
      true
    else
      false
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
