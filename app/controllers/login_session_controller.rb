class LoginSessionController < ApplicationController
  def new
  end
  
  def create
    password = params[:login_session][:password]
    email = params[:login_session][:email]
    params[:login_session][:time] = Time.now
    
    #todo have to hash the password later on
    #also todo might wanna store current user in the session, this helps: http://stackoverflow.com/questions/5761512/ruby-on-rails-global-variable
    $current_user = $person_collection.find({:email => email, :password => password}).to_a[0]
    
    if($current_user.nil?)
      flash[:notice] = "user not found!"
      redirect_to root_path
    else
      session[:current_user_email] = $current_user['email']
      redirect_to "/log_entry"
    end
  end
  
  def destroy
    $current_user = nil
    session[:current_user_email] = ""
    redirect_to "/login_session/new"
  end
end