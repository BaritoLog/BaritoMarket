class RedisCacheListener
  def initialize
  end

  def profile_response_updated(app_secret, profile_response)
    REDIS_CACHE.set(
      "#{APP_PROFILE_CACHE_PREFIX}:#{app_secret}", profile_response.to_json)
  end

  def app_destroyed(app_secret)
    REDIS_CACHE.del("#{APP_PROFILE_CACHE_PREFIX}:#{app_secret}")
  end

  def apps_destroyed(app_group_id)
    app_group = AppGroup.find(app_group_id)
    apps = app_group.barito_apps
    apps.each do |app|
      REDIS_CACHE.del("#{APP_PROFILE_CACHE_PREFIX}:#{app.secret_key}")  
    end
  end
end
