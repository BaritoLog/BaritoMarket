class SessionsController < ApplicationController
	def logout
		sign_out current_user
		redirect_to root_path
	end

end
