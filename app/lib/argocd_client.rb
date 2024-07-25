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

  def get_cluster_map()
    puts("in get_cluster map")
    cluster_map = JSON.parse(@conn.get('/api/v1/clusters').body)['items'].select { |i| i['connectionState']['status'] == 'Successful' }.map { |i| [i['name'], i['server']] }.to_h

    cluster_map
  end

  def create_application(app_group_name, override_values)
    output = @conn.post do | req |
      req.body = {
        metadata: {
          name: "#{Figaro.env.argocd_project_name}-#{app_group_name}-#{Figaro.env.argocd_default_destination_name}",
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
    output

  end

  def sync_application(app_group_name)
    output = @conn.post do | req |
      req.body = {
        project: Figaro.env.argocd_project_name,
      }.to_json
      req.path = "/api/v1/applications/#{Figaro.env.argocd_project_name}-#{app_group_name}-#{Figaro.env.argocd_default_destination_name}/sync"
    end
    output

  end
end