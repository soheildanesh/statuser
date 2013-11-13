class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include ApplicationHelper
  
  helper_method :current_user
  def current_user
    if($current_user.nil?)
      $current_user = $person_collection.find({:email => session[:current_user_email] }).to_a[0]
    end
    return $current_user
  end

end
