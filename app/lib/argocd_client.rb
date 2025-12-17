require 'time'

class ArgoCDClient
  attr_accessor :url,
                :token,
                :namespace,
                :project_name,
                :default_destination_server,
                :helm_chart_name,
                :helm_chart_version,
                :helm_chart_repository

  def initialize
    @url = Figaro.env.ARGOCD_URL
    @token = Figaro.env.ARGOCD_TOKEN
    @namespace = Figaro.env.ARGOCD_NAMESPACE
    @project_name = Figaro.env.ARGOCD_PROJECT_NAME
    @default_destination_server = Figaro.env.ARGOCD_DEFAULT_DESTINATION_SERVER
    @ssl_verify_enabled = Figaro.env.ARGOCD_SSL_VERIFY_ENABLED == 'true'
    @helm_chart_name = Figaro.env.HELM_CHART_NAME
    @helm_chart_version = Figaro.env.HELM_CHART_VERSION
    @helm_chart_repository = Figaro.env.HELM_CHART_REPOSITORY
    @faraday_client = Faraday.new(
      url: @url,
      ssl: { verify: @ssl_verify_enabled },
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@token}"
      }
    )
    
    Rails.logger.info("ArgoCDClient initialized for URL: #{@url}")
  rescue => e
    Rails.logger.error("ArgoCDClient initialization failed: #{e.class}")
    raise
  end

  def get_application_url(helm_infrastructure)
    "#{Figaro.env.ARGOCD_URL}/applications/#{Figaro.env.argocd_namespace}/#{Figaro.env.argocd_project_name}-#{helm_infrastructure.cluster_name}-#{helm_infrastructure.location_name}"
  end

  def get_application_name(app_group_name, argocd_destination_cluster)
    "#{Figaro.env.argocd_project_name}-#{app_group_name}-#{argocd_destination_cluster}"
  end

  def delete_application(app_group_name, argocd_destination_cluster)
    app_name = get_application_name(app_group_name, argocd_destination_cluster)
    Rails.logger.info("Deleting ArgoCD application: #{app_name}")
    
    response = @faraday_client.delete do | req |
      req.params['project'] = Figaro.env.ARGOCD_PROJECT_NAME
      req.path = "/api/v1/applications/#{app_name}"
    end
    
    Rails.logger.info("Delete application response status: #{response.status}")
    response
  rescue => e
    Rails.logger.error("Failed to delete application #{app_name}: #{e.class}")
    raise
  end

  def get_cluster_map
    Rails.logger.info("Fetching ArgoCD cluster map")
    
    response = @faraday_client.get('/api/v1/clusters')
    cluster_map = JSON.parse(response.body)['items']
      .select { |i| i['connectionState']['status'] == 'Successful' }
      .map { |i| [i['name'], i['server']] }
      .to_h
    
    Rails.logger.info("Cluster map retrieved with #{cluster_map.size} clusters")
    cluster_map
  rescue => e
    Rails.logger.error("Failed to get cluster map: #{e.class}")
    raise
  end

  def create_application(app_group_name, override_values, argocd_destination_cluster_name, argocd_destination_server)
    app_name = get_application_name(app_group_name, argocd_destination_cluster_name)
    Rails.logger.info("Creating ArgoCD application: #{app_name}")
    
    response = @faraday_client.post do | req |
      req.body = {
        metadata: {
          name: app_name,
          namespace: Figaro.env.argocd_namespace,
        },
        spec: {
          destination: {
            server: argocd_destination_server,
            namespace: Figaro.env.argocd_destination_namespace,
          },
          project: Figaro.env.argocd_project_name,
          source: {
            repoURL: Figaro.env.helm_repository,
            chart: Figaro.env.helm_chart_name,
            targetRevision: Figaro.env.helm_chart_version,
            helm: {
              releaseName: app_group_name,
              values: YAML.dump(override_values),
            }
          }
        }
      }.to_json
      req.params['upsert'] = true
      req.path = '/api/v1/applications'
    end
    
    Rails.logger.info("Create application response status: #{response.status}")
    response
  rescue => e
    Rails.logger.error("Failed to create application #{app_name}: #{e.class}")
    raise
  end

  def sync_application(app_group_name, argocd_destination_cluster)
    app_name = get_application_name(app_group_name, argocd_destination_cluster)
    Rails.logger.info("Syncing ArgoCD application: #{app_name}")
    
    response = @faraday_client.post do | req |
      req.body = {
        project: Figaro.env.argocd_project_name,
        prune: true,
      }.to_json
      req.path = "/api/v1/applications/#{app_name}/sync"
    end
    
    Rails.logger.info("Sync application response status: #{response.status}")
    response
  rescue => e
    Rails.logger.error("Failed to sync application #{app_name}: #{e.class}")
    raise
  end

  def terminate_operation(app_group_name, argocd_destination_cluster)
    app_name = get_application_name(app_group_name, argocd_destination_cluster)
    Rails.logger.info("Terminating operation for application: #{app_name}")
    
    response = @faraday_client.delete do | req |
      req.path = "/api/v1/applications/#{app_name}/operation"
    end
    
    Rails.logger.info("Terminate operation response status: #{response.status}")
    response
  rescue => e
    Rails.logger.error("Failed to terminate operation for #{app_name}: #{e.class}")
    raise
  end

  def check_sync_operation_status(app_group_name, argocd_destination_cluster)
    app_name = get_application_name(app_group_name, argocd_destination_cluster)
    Rails.logger.info("Checking sync operation status for: #{app_name}")
    
    response = @faraday_client.get("/api/v1/applications/#{app_name}")
    
    if response.env[:status] == 200
      app_status = JSON.parse(response.body)['status']

      if !app_status.dig("operationState", "message") || !app_status.dig("operationState", "phase")
        Rails.logger.warn("Application #{app_name} not synced")
        return 'Argo Application not synced.', 'Argo Application is not synced'
      end

      phase = app_status['operationState']['phase']
      message = app_status['operationState']['message']
      Rails.logger.info("Sync status for #{app_name}: phase=#{phase}")
      
      return message, phase
    else
      Rails.logger.warn("Application #{app_name} not found, status: #{response.env[:status]}")
      return 'Argo Application is not created.', 'Argo Application is not created'
    end
  rescue => e
    Rails.logger.error("Failed to check sync status for #{app_name}: #{e.class}")
    raise
  end

  def check_application_health_status(app_group_name, argocd_destination_cluster)
    app_name = get_application_name(app_group_name, argocd_destination_cluster)
    Rails.logger.info("Checking health status for: #{app_name}")
    
    response = @faraday_client.get("/api/v1/applications/#{app_name}")
    
    if response.env[:status] == 200
      app_status = JSON.parse(response.body)['status']
      health_status = app_status['health']['status']
      Rails.logger.info("Health status for #{app_name}: #{health_status}")
      return health_status
    else
      Rails.logger.warn("Application #{app_name} not found, status: #{response.env[:status]}")
      return 'Argo Application is not created.'
    end
  rescue => e
    Rails.logger.error("Failed to check health status for #{app_name}: #{e.class}")
    raise
  end

  def sync_duration(app_group_name, argocd_destination_cluster)
    app_name = get_application_name(app_group_name, argocd_destination_cluster)
    Rails.logger.info("Calculating sync duration for: #{app_name}")
    
    response = @faraday_client.get("/api/v1/applications/#{app_name}")
    
    if response.env[:status] == 200
      app_status = JSON.parse(response.body)['status']
      
      if !app_status.dig("operationState", "startedAt")
        Rails.logger.info("Application #{app_name} was not synced")
        return 'Argo application was not synced'
      end
      
      start_time = Time.parse(app_status['operationState']['startedAt'])
      
      if !app_status.dig("operationState", "finishedAt")
        Rails.logger.info("Application #{app_name} still syncing")
        return 'Argo application still syncing'
      else
        end_time = Time.parse(app_status['operationState']['finishedAt'])
        difference_in_seconds = end_time - start_time

        hours = (difference_in_seconds / 3600).to_i
        minutes = ((difference_in_seconds % 3600) / 60).to_i
        seconds = (difference_in_seconds % 60).to_i

        duration = "#{hours} hours, #{minutes} minutes, and #{seconds} seconds"
        Rails.logger.info("Sync duration for #{app_name}: #{duration}")
        return duration
      end
    else
      Rails.logger.warn("Application #{app_name} not found, status: #{response.env[:status]}")
      return 'Argo Application is not created.'
    end
  rescue => e
    Rails.logger.error("Failed to calculate sync duration for #{app_name}: #{e.class}")
    raise
  end
end
