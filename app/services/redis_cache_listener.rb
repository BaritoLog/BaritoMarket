class RedisCacheListener
  def initialize
  end

  def profile_response_updated(app_secret, profile_response)
    REDIS_CACHE.set(
      "#{APP_PROFILE_CACHE_PREFIX}:#{app_secret}", profile_response.to_json)
  end

  def redact_response_updated(cluster_name, all_labels)
    REDIS_CACHE.set(
      "#{APP_GROUP_REDACT_LABELS}:#{cluster_name}", all_labels.to_json)
  end

  def app_group_profile_response_updated(app_group_secret, app_name, profile_response)
    REDIS_CACHE.set(
      "#{APP_GROUP_PROFILE_CACHE_PREFIX}:#{app_group_secret}:#{app_name}", profile_response.to_json)
  end

  def app_destroyed(app_group_secret, app_secret, app_name)
    REDIS_CACHE.del("#{APP_PROFILE_CACHE_PREFIX}:#{app_secret}")
    REDIS_CACHE.del("#{APP_GROUP_PROFILE_CACHE_PREFIX}:#{app_group_secret}:#{app_name}")
  end

  def app_updated(app_group_secret, app_secret, app_name)
    REDIS_CACHE.del("#{APP_PROFILE_CACHE_PREFIX}:#{app_secret}")
    REDIS_CACHE.del("#{APP_GROUP_PROFILE_CACHE_PREFIX}:#{app_group_secret}:#{app_name}")
  end

  def redact_labels_updated(cluster_name)
    REDIS_CACHE.del("#{APP_GROUP_REDACT_LABELS}:#{cluster_name}")
  end

  def expire_app_group_profile(app_group_id)
    app_group = AppGroup.find(app_group_id)
    apps = app_group.barito_apps
    apps.each do |app|
      REDIS_CACHE.del("#{APP_PROFILE_CACHE_PREFIX}:#{app.secret_key}")
      REDIS_CACHE.del("#{APP_GROUP_PROFILE_CACHE_PREFIX}:#{app_group.secret_key}:#{app.name}")
    end
  end

  def app_group_updated(app_group_id)
    app_group = AppGroup.find(app_group_id)
    apps = app_group.barito_apps
    apps.each do |app|
      REDIS_CACHE.del("#{APP_PROFILE_CACHE_PREFIX}:#{app.secret_key}")
      REDIS_CACHE.del("#{APP_GROUP_PROFILE_CACHE_PREFIX}:#{app_group.secret_key}:#{app.name}")
    end
  end

  def gate_group_response_updated(username, gate_group_response)
    REDIS_CACHE.set(
      "#{GATE_GROUP_CACHE_PREFIX}:#{username}", gate_group_response)
    REDIS_CACHE.expire("#{GATE_GROUP_CACHE_PREFIX}:#{username}", Figaro.env.redis_key_expiry.to_i)
  end
end
