class PersonController < ApplicationController
  
    def destroy
        if(current_user.nil?)
            redirect_to controller:'login_session', action:'new'
            return
        elsif(current_user['role'] != 'admin')
            redirect_to controller:'login_session', action:'new'
            return
        else
            $person_collection.remove({_id: params['id'].to_i})
            redirect_to controller:'person', action:'index'
            return
        end
    end
    
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
            if(params.has_key?("q")) #(initially at least) used by tokeninput.js plugin
                searchString = ".*#{params['q']}.*"
                @persons = $person_collection.find({'email' => Regexp.new(searchString)})
            else
                flash[:notice] = "only an admin can see list of people!"
                redirect_to :controller => 'log_entry', :action => 'index'
                return
            end
        else
            if(params.has_key?("q")) #(initially at least) used by tokeninput.js plugin
                searchString = ".*#{params['q']}.*"
                @persons = $person_collection.find({'email' => Regexp.new(searchString)})
            else
                @persons = $person_collection.find().to_a.reverse
            end
        end
        respond_to do |format|
            format.html
            format.json { render :json => @persons.map{ |person| { 'name' => person['email'], 'id'=> person['_id'] } } } #convert to the {id:...,  name:... format that tokeninput.js likes}
        end
    end
  
    def new
    end
  
    def create
        
        if(current_user.nil?)
            flash[:notice] = "only an admin can create other users!"
            render :controller => 'log_entry', :action => 'index'
            return
        
        elsif( current_user['role'] != 'admin')
        
            flash[:notice] = "only an admin can create other users!"
            render :controller => 'log_entry', :action => 'index'
            return
        
        else
            
            #check to see if the person already exists, 
            existing_person = ($person_collection.find({:email => params[:person][:email]}).to_a)[0]

            if(!existing_person.nil?)
                flash[:notice] = "Person with this email exists already, can't use email to create new person"
            else
                #produce an incremented id
                last_entry = $person_collection.find().sort( :_id => :desc ).to_a
                if(last_entry[0].nil? or last_entry.empty?)
                    id = 1
                else
                    id = last_entry[0]['_id'] + 1
                end
                params[:person]['_id'] = id
                
                params[:person][:time] = Time.now
                params[:person][:email].downcase! 
                
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
        redirect_to controller:'person', action:'index'
    end
end
