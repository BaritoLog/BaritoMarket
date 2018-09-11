class GateClient
  attr_accessor :user, :url, :opts

  def initialize(user, opts = {})
    @user = user
    @opts = opts
    @url = @opts[:url] || Figaro.env.gate_url
    @access_token = @opts[:access_token] || Figaro.env.gate_access_token
  end

  def check_user_groups
    uri = URI(@url + '/nss/user/groups.json')
    uri.query = URI.encode_www_form(
      email: @user.username,
      token: @access_token,
    )
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
