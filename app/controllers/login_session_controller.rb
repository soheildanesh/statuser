class LoginSessionController < ApplicationController
  def new
  end
  
  def create
    password = params[:login_session][:password]
    email = params[:login_session][:email].downcase
    params[:login_session][:time] = Time.now
    
    #todo have to encrypt the password later on
    #also todo might wanna store current user in the session, this helps: http://stackoverflow.com/questions/5761512/ruby-on-rails-global-variable
   get_current_user = $person_collection.find({:email => email, :password => password}).to_a[0]
    
    if(get_current_user.nil?)
      not get_current_user[:error] = "user not found!"
      redirect_to "/login_session/new"
    else
        if not get_current_user.nil? and not get_current_user.has_key? 'customerMode'
           get_current_user['customerMode'] = {'customerId'=>"All Customers"}
            $person_collection.save( get_current_user)
        end
        
        
        #session[:current_user_email] = $current_user['email']
        session[:current_user_id] =get_current_user['_id']
            
            
        redirect_to "/project"
    end
  end
  
  def destroy
    #session[:current_user_email] = ""
    session[:current_user_id] = nil
    redirect_to "/login_session/new"
  end
end