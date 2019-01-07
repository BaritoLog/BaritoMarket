class GateClient
  attr_accessor :user, :url, :opts
  include Wisper::Publisher

  def initialize(user, opts = {})
    @user = user
    @opts = opts
    @url = @opts[:url] || Figaro.env.gate_url
    @access_token = @opts[:access_token] || Figaro.env.gate_access_token
  end

  def check_user_groups
    check_user_groups_json = REDIS_CACHE.get(
      "#{GATE_GROUP_CACHE_PREFIX}:#{@user.username}")

    if check_user_groups_json.present?
      return JSON.parse(check_user_groups_json)
    end

    uri = URI(@url + '/nss/user/groups.json')
    uri.query = URI.encode_www_form(
      email: @user.username,
      token: @access_token,
    )
    response = Net::HTTP.get(uri)
    broadcast(:gate_group_response_updated,
      @user.username, response)

    JSON.parse(response)
  end
end
