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
  end
