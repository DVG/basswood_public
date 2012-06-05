class ApplicationController < ActionController::Base
  before_filter :set_current_user
  
  protect_from_forgery
  def permission_denied
    flash[:error] = "Sorry, you not allowed to access that page."
    redirect_to root_url
  end
   protected
   def set_current_user
     Authorization.current_user = current_user
   end

end
