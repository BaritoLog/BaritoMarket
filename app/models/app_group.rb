class AppGroup < ApplicationRecord
  validates :name, :secret_key, presence: true
  validates :name, uniqueness: true

  has_many :barito_apps
  has_many :app_group_users
  has_many :users, through: :app_group_users
  has_many :app_group_bookmarks
  has_many :app_group_teams
  has_many :groups, through: :app_group_teams
  has_one :infrastructure
  belongs_to :producer_helm_infrastructure, class_name: 'HelmInfrastructure', foreign_key: 'producer_helm_infrastructure_id'
  belongs_to :kibana_helm_infrastructure, class_name: 'HelmInfrastructure', foreign_key: 'kibana_helm_infrastructure_id'
  has_many :helm_infrastructures

  enum environment: {
    staging: 'STAGING',
    production: 'PRODUCTION',
  }

  enum redact_statuses: {
    inactive: 'INACTIVE',
    active: 'ACTIVE',
  }
  enum status: { ACTIVE: 0, INACTIVE: 1 }

  scope :active, -> {
    includes(:helm_infrastructures).
      includes(:barito_apps).
      where.not(helm_infrastructures: { provisioning_status: 'DELETED' })
  }

  after_update :expire_cache

  filterrific default_filter_params: { sorted_by: 'created_at_desc' },
              available_filters: %w[
                sorted_by
                search_query
                search_by_labels
              ]

  scope :search_query, ->(query) {
    return nil if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map do |e|
      ('%' + e + '%').gsub(/%+/, '%')
    end
    num_or_conditions = 3
    where(
      terms.map do
        or_clauses = [
          'LOWER(app_groups.name) LIKE ?',
          'LOWER(helm_infrastructures.cluster_name) LIKE ?',
          'LOWER(barito_apps.name) LIKE ?'
        ].join(' OR ')
        "(#{or_clauses})"
      end.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten,
    )
  }

  scope :search_by_labels, ->(query) {
    return nil if query.blank?

    queries = []
    values = []
    query.each_pair do |k,v|
      if k.blank? || v.blank?
        next
      end

      if k.to_s.starts_with?("keys_")
        queries.append("app_groups.labels->>? LIKE ?")
      end

      if k.to_s.starts_with?("values_")
        values.append("%#{v}%")
      else
        values.append(v)
      end
    end

    where(
      queries.join(' AND '),
      *values
    )
  }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    app_groups = AppGroup.arel_table
    case sort_option.to_s
    when /^created_at_/
      order(app_groups[:created_at].send(direction))
    when /^name_/
      order(app_groups[:name].lower.send(direction))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.setup(params)
    log_retention_days = nil
    environment = "staging"
    unless Figaro.env.default_log_retention_days.blank?
      log_retention_days = Figaro.env.default_log_retention_days.to_i
    end
    log_retention_days = params[:log_retention_days].to_i unless params[:log_retention_days].blank?

    if params[:labels].nil? || params[:labels].empty?
      labels = {}
    else
      labels = params[:labels]
    end

    if params[:redact_labels].nil? || params[:redact_labels].empty?
      redact_labels = {}
    else
      redact_labels = params[:redact_labels]
    end

    if params[:environment]&.downcase&.include?"production"
      environment = "production"
    end

    ActiveRecord::Base.transaction do
      cluster_name = AppGroup.generate_cluster_name
      app_group = AppGroup.create(
        name: params[:name],
        secret_key: AppGroup.generate_key,
        log_retention_days: log_retention_days,
        environment: environment,
        cluster_name: cluster_name,
        labels: labels,
        redact_labels: redact_labels,
        redact_status: "INACTIVE",
        status: :ACTIVE,
        max_tps: Figaro.env.DEFAULT_MAX_TPS
      )

      infrastructure_location = InfrastructureLocation.active.find_by(name: Figaro.env.default_infrastructure_location)
      if params[:infrastructure_location_name].present?
        infrastructure_location = InfrastructureLocation.active.find_by(name: params[:infrastructure_location_name])
      end

      helm_infrastructure = HelmInfrastructure.setup(
        app_group_id: app_group.id,
        helm_cluster_template_id: params[:cluster_template_id],
        infrastructure_location_id: infrastructure_location.id,
        cluster_name: cluster_name
      )


      app_group.kibana_helm_infrastructure_id = helm_infrastructure.id
      app_group.producer_helm_infrastructure_id = helm_infrastructure.id
      app_group.save!


      [app_group, helm_infrastructure]
    end
  end

  def redact_active?
    self.redact_status == AppGroup.redact_statuses[:active]
  end

  def app_group_active?
    self.status == "ACTIVE"
  end

  def self.generate_cluster_name
    column = 'cluster_index'
    query = "SELECT nextval('cluster_index_seq') AS #{column}"
    cluster_index = connection.execute(query).first[column]
    Rufus::Mnemo.from_i(cluster_index)
  end

  def helm_infrastructure_in_default_location
    infrastructure_location = InfrastructureLocation.active.find_by(name: Figaro.env.default_infrastructure_location)
    self.helm_infrastructures.where(infrastructure_location_id: infrastructure_location.id).first if infrastructure_location.present?
  end

  def increase_log_count(new_count)
    update_column(:log_count, log_count + new_count.to_i)
  end

  def self.generate_key
    SecureRandom.uuid.gsub(/\-/, '')
  end

  def available?
    helm_infrastructures.active.first.present?
  end

  def latest_total_cost
    barito_apps.sum(:latest_cost)
  end

  def latest_total_ingested_log_bytes
    barito_apps.sum(:latest_ingested_log_bytes)
  end

  def new_total_tps(diff_tps)
    barito_apps.sum(:max_tps) + diff_tps
  end

  def get_producer_helm_infrastructure
    if producer_helm_infrastructure_id.nil?
      helm_infrastructure = helm_infrastructure_in_default_location if helm_infrastructure.nil?
      helm_infrastructure = helm_infrastructures.active.first if helm_infrastructure.nil?
    else
      helm_infrastructure = producer_helm_infrastructure
    end
    helm_infrastructure
  end

  def producer_mtls_enabled?
    get_producer_helm_infrastructure&.infrastructure_location.is_mtls_enabled ? true : false
  end

  def producer_address
    get_producer_helm_infrastructure&.producer_address
  end

  def get_kibana_helm_infrastructure
    if kibana_helm_infrastructure_id.nil?
      helm_infrastructure = helm_infrastructure_in_default_location if helm_infrastructure.nil?
      helm_infrastructure = helm_infrastructures.active.first if helm_infrastructure.nil?
    else
      helm_infrastructure = kibana_helm_infrastructure
    end
    helm_infrastructure
  end

  def kibana_mtls_enabled?
    get_kibana_helm_infrastructure&.infrastructure_location.is_mtls_enabled ? true : false
  end

  def kibana_address
    get_kibana_helm_infrastructure&.kibana_address
  end

  def elasticsearch_address
    elasticsearch_address_format = Figaro.env.ES_ADDRESS_FORMAT
    sprintf(elasticsearch_address_format, cluster_name)
  end

  def expire_cache
    CacheHelper.expire_app_group_profile(id)
  end
end
