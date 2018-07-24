class GateWrapper
  attr_accessor :user, :url, :options

  def initialize(user, options = {})
    @options = options
    @url = Figaro.env.gate_url
    @user = user
  end

  def check_user_groups
    uri = URI(@url + '/nss/user/groups.json')
    uri.query = URI.encode_www_form({ email: @user.username, token: Figaro.env.gate_access_token })
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
