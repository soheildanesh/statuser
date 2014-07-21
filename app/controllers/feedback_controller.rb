class FeedbackController < ApplicationController
  
    def destroy
        if(get_current_user.nil?)
            not get_current_user[:notice] = "log in to delete"
            redirect_to controller:'login_session', action:'new'
            return
        elsif(get_current_user['role'] != 'admin')
            not get_current_user[:notice] = "only an admin can delete"
            redirect_to controller:'login_session', action:'new'
            return
        else
            $feedback_collection.remove({:_id => BSON::ObjectId(params['id']) })
            redirect_to controller:'feedback', action:'index'
            return
        end
    end
    
    def show

    end
  
    def index

        @feedbacks = $feedback_collection.find()

        respond_to do |format|
            format.html
        end
    end
  
    def new
    end
  
    def create
        
        if(get_current_user.nil?)
            not get_current_user[:notice] = "log in to create"
            render :controller => 'feedback', :action => 'new'
            return        
        else   
            params["feedback"]['createdAt'] = Time.now                
            params["feedback"]['createdBy'] = get_current_user['_id']
            
            $feedback_collection.insert(params["feedback"])
            #ensure the insert happened
            mongodbLastError = $testDb.get_last_error({:w => 1})
            if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
                raise "mongodb returend error after write, write might not have happened!"  
            end
        end
        
        not get_current_user[:notice] = "Thank you for your feedback!"
        redirect_to controller:'project', action:'index'
    end
end
