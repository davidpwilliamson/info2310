class StaticPagesController < ApplicationController
  def home
    if signed_in?
	  @micropost = Micropost.new
      @feed = current_user.feed(page: params[:page])
    end
  end

  def help
  end
  
  def about
  end
end
