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
    @helm_chart_name = Figaro.env.HELM_CHART_NAME
    @helm_chart_version = Figaro.env.HELM_CHART_VERSION
    @helm_chart_repository = Figaro.env.HELM_CHART_REPOSITORY
    @conn = Faraday.new(
      url: @url,
      headers: {
          "Content-Type" => "application/json",
          "Authorization": "Bearer " + @token
      }
    )
  end

  def get_application_name(app_group_name, argocd_destination_cluster)
    return "#{Figaro.env.argocd_project_name}-#{app_group_name}-#{argocd_destination_cluster}"
  end

  def delete_application(app_group_name, argocd_destination_cluster)
    return @conn.delete do | req |
      req.params['project'] = Figaro.env.ARGOCD_PROJECT_NAME
      req.path = "/api/v1/applications/#{get_application_name(app_group_name, argocd_destination_cluster)}"
    end
  end

  def get_cluster_map()
    return JSON.parse(@conn.get('/api/v1/clusters').body)['items'].select { |i| i['connectionState']['status'] == 'Successful' }.map { |i| [i['name'], i['server']] }.to_h
  end

  def create_application(app_group_name, override_values, argocd_destination_cluster)
    return @conn.post do | req |
      req.body = {
        metadata: {
          name: get_application_name(app_group_name, argocd_destination_cluster),
          namespace: Figaro.env.argocd_namespace
        },
        spec: {
          destination: {
            server: Figaro.env.argocd_default_destination_server,
            namespace: Figaro.env.argocd_destination_namespace
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
  end

  def sync_application(app_group_name, argocd_destination_cluster)
    return @conn.post do | req |
      req.body = {
        project: Figaro.env.argocd_project_name,
      }.to_json
      req.path = "/api/v1/applications/#{get_application_name(app_group_name, argocd_destination_cluster)}/sync"
    end
  end

  def terminate_operation(app_group_name, argocd_destination_cluster)
    path = "/api/v1/applications/#{get_application_name(app_group_name, argocd_destination_cluster)}/operation"
    logger.info "debug terminate_operation: #{path}"
    return @conn.delete do | req |
      req.path = path
    end
  end

  def check_sync_operation_status(app_group_name, argocd_destination_cluster)
    response = @conn.get("/api/v1/applications/#{get_application_name(app_group_name, argocd_destination_cluster)}")
    if response.env[:status] == 200
      app_status = JSON.parse(response.body)['status']

      if !app_status.dig("operationState", "message") || !app_status.dig("operationState", "phase")
        return 'Argo Application not synced.', 'Argo Application is not synced'
      end

      return app_status['operationState']['message'], app_status['operationState']['phase']
    else
      return 'Argo Application is not created.', 'Argo Application is not created'
    end
    
    #  phase = Failed, Running, Succeeded
    #  message = Operation terminated, any, successfully synced (all tasks run)
  end

  def check_application_health_status(app_group_name, argocd_destination_cluster)
    response = @conn.get("/api/v1/applications/#{get_application_name(app_group_name, argocd_destination_cluster)}")
    if response.env[:status] == 200
      app_status = JSON.parse(response.body)['status']
      return app_status['health']['status']
    else
      return 'Argo Application is not created.'
    end
  end

  def sync_duration(app_group_name, argocd_destination_cluster)
    response = @conn.get("/api/v1/applications/#{get_application_name(app_group_name, argocd_destination_cluster)}")
    if response.env[:status] == 200
      app_status = JSON.parse(response.body)['status']
      if !app_status.dig("operationState", "startedAt")
        return 'Argo application was not synced'
      end
      start_time = Time.parse(app_status['operationState']['startedAt'])
      end_time = ''
      if !app_status.dig("operationState", "finishedAt")
        return 'Argo application still syncing'
      else
        end_time = Time.parse(app_status['operationState']['finishedAt'])
        difference_in_seconds = end_time - start_time
  
        hours = (difference_in_seconds / 3600).to_i
        minutes = ((difference_in_seconds % 3600) / 60).to_i
        seconds = (difference_in_seconds % 60).to_i
  
        return "#{hours} hours, #{minutes} minutes, and #{seconds} seconds"
      end
    else
      return 'Argo Application is not created.'
    end
  end
end
