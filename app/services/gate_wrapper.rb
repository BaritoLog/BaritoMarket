class GateWrapper
  attr_accessor :user, :url, :options

  def initialize(user, options = {})
    @options = options
    @url = Figaro.env.gate_url
    @user = user
  end

  def check_user_groups
    uri = URI(@url + '/nss/user/groups.json')
    uri.query = URI.encode_www_form({ email: @user.email, token: @user.auth_token })
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def get_user_profile
    uri = URI(@url + '/users/profile')
    uri.query = URI.encode_www_form({ token: @user.auth_token })
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
