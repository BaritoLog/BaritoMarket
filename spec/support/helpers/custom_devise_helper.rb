module CustomDeviseHelper
  def sign_in(user = instance_double(User, to_key: 1, authenticatable_salt: 'example'))
    login_as(user)
  end
end
