class RedisCacheListener
  def initialize
  end

  def profile_response_updated(app_secret, profile_response)
    REDIS_CACHE.set("APP_PROFILE_CACHE_PREFIX:#{app_secret}", profile_response)
  end

  def app_destroyed(app_secret)
    REDIS_CACHE.del("APP_PROFILE_CACHE_PREFIX:#{app_secret}")
  end
end
