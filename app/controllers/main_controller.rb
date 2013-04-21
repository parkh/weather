class MainController < ApplicationController

  def index
  	if session[:user_id] == nil
  	  @cities = []
  	else
  	  @cities = City.where(user_id: session[:user_id]).order('updated_at DESC')
  	end
  end

end

