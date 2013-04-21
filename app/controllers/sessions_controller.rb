class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.authenticate(params[:name], params[:password])
  	if user
  	  session[:user_id] = user.id
  	  redirect_to root_path, notice: 'Залогинились!'
  	else
  	  flash.now.alert = 'Нет такого пользователя!'
  	  render 'new'
  	end
  end

  def destroy
  	session[:user_id] = nil
  	redirect_to root_path, notice: 'Отлогинились...'
  end

end
