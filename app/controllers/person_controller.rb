class PersonController < ApplicationController
    
    #just cuz views don't have access to class variables so each method gets its own instance variable
    before_action :setsRolesInstanceVariable
    @@roles = ["project manager admin", "project manager", "admin", "project controller"]    
    def setsRolesInstanceVariable
        @roles = @@roles
    end
    
    def edit
        
        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end
        role = current_user['role']
        if not( role == 'admin' )
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        @person = $person_collection.find({"_id" => params['id'].to_i } ).to_a[0]
        
        @preroleHash = Hash.new
        
        for role in @@roles
            @preroleHash[role] = nil
        end
        @preroleHash[@person['role']] = {checked: "checked"}
    end
  
    def changeMode
        #prolly have to check person's authorization here later on
        if(params['person']["customerMode"]['customerId'] == "")
            current_user['customerMode']['customerId'] =  "All Customers"
        else
            current_user['customerMode'] = params['person']["customerMode"]
        end
        $person_collection.save(current_user)
        redirect_to controller: 'list', action: 'index'
    end
    
    def update
        
        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end
        role = current_user['role']
        if not( role == 'admin' )
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        if(not current_user.nil?)
             if(not current_user['role'] == 'admin')
                 flash[:notice] = "Have to be admin user for this"
                 render '/login_session/new'
                 return
             end
        else
            flash[:notice] = "Have to be logged in for this"
            render '/login_session/new'
            return
        end



        #find and remove record to be updated
        record = $person_collection.find({"_id" => params['id'].to_i } ).to_a[0]

        params['person'].each do |key, value| 
            if key == '_id'
                next
            end
            record[key] = value
        end

        $person_collection.save(record)

        redirect_to controller: "person", action: "index"
        
    end
    
    def destroy
        
        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end
        role = current_user['role']
        if not( role == 'admin' )
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
        $person_collection.remove({_id: params['id'].to_i})
        redirect_to controller:'person', action:'index'
        return
        
    end
    
    def show
        
        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end
        role = current_user['role']
        if not( role == 'admin' )
            flash[:error] = "User not authorized"
            redirect_to controller: 'project', action: 'index'
            return
        end
        
        if(params[:id].nil?)
            #in this case it shows the current user's log entries
            redirect_to :controller => 'log_entry', :action => 'index'
        else
            redirect_to :controller => 'log_entry', :action => 'index', :id => params[:id]
        end
    end
  
    def index
        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render  controller: 'login_session', :action => 'new'
            return
        end
        role = current_user['role']
        if false and not( role == 'admin' )
            flash[:error] = "User not authorized"
            redirect_to controller: 'project', action: 'index'
            return
        end
        
        if(!current_user.nil? and current_user['role'] != 'admin')
            if(params.has_key?("q")) #(initially at least) used by tokeninput.js plugin
                searchString = ".*#{params['q']}.*"
                @persons = $person_collection.find({'email' => Regexp.new(searchString, "i")})
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
            flash[:notice] = "User not logged in"
            render  controller: 'login_session', :action => 'new'
            return
        end
        role = current_user['role']
        if not( role == 'admin' )
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
            
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
    
    
      
        @allPersons = $person_collection.find().to_a.reverse
        redirect_to controller:'person', action:'index'
    end
end
