class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	def google_oauth2
		account = request.env['omniauth.auth']
		email = account.info.email
		
		unless User.valid_email_domain?(email)
			flash[:alert] = 'Email domain not valid'
			redirect_to new_user_session_path, event: :authentication
      return
		end

		@user = User.find_or_create_by_email(email)
		if @user && @user.deactivated_at.nil?
			sign_in_and_redirect @user, event: :authentication
		else
			flash[:alert] = 'There is something wrong, please contact the administrator'
			redirect_to new_user_session_path, event: :authentication
		end
	end

    def failure
      flash[:alert] = 'There is something wrong, please contact the administrator'
    	redirect_to new_user_session_path
    end
 end
