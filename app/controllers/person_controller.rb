class PersonController < ApplicationController
  
    def show
        if(params[:id].nil?)
            #in this case it shows the current user's log entries
            redirect_to :controller => 'log_entry', :action => 'index'
        else
            redirect_to :controller => 'log_entry', :action => 'index', :id => params[:id]
        end
    end
  
    def index
        if(!current_user.nil? and current_user['role'] != 'admin')
            flash[:notice] = "only an admin can see list of people!"
            redirect_to :controller => 'log_entry', :action => 'index'
            return
        else
            @allPersons = $person_collection.find().to_a.reverse
        end
    end
  
    def new
    end
  
    def create
      
        if( !current_user.nil? and current_user['role'] != 'admin')
        
            flash[:notice] = "only an admin can create other users!"
            render :controller => 'log_entry', :action => 'index'
            return
        
        else
            
            #check to see if the person already exists, 
            existing_person = ($person_collection.find({:email => params[:person][:email]}).to_a)[0]

            if(!existing_person.nil?)
                flash[:notice] = "Person with this email exists already, can't use email to create new person"
            else
                params[:person][:time] = Time.now
                
                #otherwise insert him into database
                $person_collection.insert(params[:person])
                #ensure the insert happened
                mongodbLastError = $testDb.get_last_error({:w => 1})
                if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
                    raise "mongodb returend error after write, write might not have happened!"  
                end
            end
        
        end
      
        @allPersons = $person_collection.find().to_a.reverse
        render 'index'
    end
end
