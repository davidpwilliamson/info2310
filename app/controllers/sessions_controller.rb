class SessionsController < ApplicationController

  before_filter :redirect_home_if_signed_in, only: [:new, :create]

  def new
  end

  def create
	user = User.authenticate(params[:session][:email], params[:session][:password])
	
	if user 
		flash[:notice] = "Welcome, #{user.email}!"
		sign_in(user)
		redirect_to user_path(user)
	else
		flash[:error] = "Invalid email/password combination"
		redirect_to new_session_path
	end
  end

  def destroy
	user = current_user
	flash[:notice] = "Logged out #{user.email}"
	sign_out_user
	redirect_to root_path
  end

end

