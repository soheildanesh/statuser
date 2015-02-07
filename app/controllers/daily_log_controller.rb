class DailyLogController < ApplicationController
  def index
    if params.has_key? 'id'
      projId = params['id']
    else
      projId = nil
    end
    
    if projId.nil?
      #read all daily logs
      $daily_log_collection.find()
    else
      #read daily logs for this project only
      @logs = $daily_log_collection.find({"project_id" => projId } ).to_a
    end
  end
  
  def new
    if(get_current_user.nil?)
        flash[:notice] = "User not logged in"
        render controller: 'login_session', action: 'new'
        return
    end
    role =get_current_user['role']
    if not( role == 'admin' or role == 'project controller')
        flash[:error] = "User not authorized"
        redirect_to action: 'index'
        return
    end
    
    @projId = params['id']
    
    if @projId.nil?
      flash[:error] = "No Project Specified!"
      redirect_to controller: 'project', action: 'index'
      return
    end
  end
  
  def create
    if(get_current_user.nil?)
        flash[:notice] = "User not logged in"
        render controller: 'login_session', action: 'new'
        return
    end
    role =get_current_user['role']
    if not( role == 'admin' or role == 'project controller')
        flash[:error] = "User not authorized"
        redirect_to action: 'index'
        return
    end
    
    @projId = params['projId']
    
    #add man hours to project's total man hours
    
    #save daily log entry
    


    
  end
end