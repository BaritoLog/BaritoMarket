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
  has_one :helm_infrastructure

  enum environment: {
    staging: 'STAGING',
    production: 'PRODUCTION',
  }

  scope :active, -> {
    includes(:helm_infrastructure).
      includes(:barito_apps).
      where.not(helm_infrastructures: { provisioning_status: 'DELETED' })
  }

  filterrific default_filter_params: { sorted_by: 'created_at_desc' },
              available_filters: %w[
                sorted_by
                search_query
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
    unless Figaro.env.default_log_retention_days.blank?
      log_retention_days = Figaro.env.default_log_retention_days.to_i
    end
    log_retention_days = params[:log_retention_days].to_i unless params[:log_retention_days].blank?

    ActiveRecord::Base.transaction do
      app_group = AppGroup.create(
        name: params[:name],
        secret_key: AppGroup.generate_key,
        log_retention_days: log_retention_days,
        environment: params[:environment],
      )

      helm_infrastructure = HelmInfrastructure.setup(
        app_group_id: app_group.id,
        helm_cluster_template_id: params[:cluster_template_id],
      )

      [app_group, helm_infrastructure]
    end
  end

  def increase_log_count(new_count)
    update_column(:log_count, log_count + new_count.to_i)
  end

  def self.generate_key
    SecureRandom.uuid.gsub(/\-/, '')
  end

  def available?
    helm_infrastructure.nil? ? false : helm_infrastructure.active?
  end

  def max_tps
    helm_infrastructure.nil? ? 0 : helm_infrastructure.max_tps
  end

  def new_total_tps(diff_tps)
    barito_apps.sum(:max_tps) + diff_tps
  end
end
