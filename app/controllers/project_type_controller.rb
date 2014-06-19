class ProjectTypeController < ApplicationController
  
    def destroy
        if(current_user.nil?)
            flash[:notice] = "log in to  delete"
            redirect_to controller:'login_session', action:'new'
            return
        elsif(current_user['role'] != 'admin')
            flash[:notice] = "only an admin can delete"
            redirect_to controller:'login_session', action:'new'
            return
        else
            $projectType_collection.remove({:_id => BSON::ObjectId(params['id']) })
            redirect_to controller:'project_type', action:'index'
            return
        end
    end
    
    def show

    end
  
    def index
        
        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end



        if(params.has_key?("q"))
            searchString = ".*#{params['q']}.*"
            @projectTypes = $projectType_collection.find({'projectTypeName' => Regexp.new(searchString, "i")})
        else
            @projectTypes = $projectType_collection.find()
        end
            
        
        respond_to do |format|
            format.html
            format.json { render :json => @projectTypes.map{ |projectType| { 'name' => projectType['projectTypeName'], 'id'=> projectType['_id'].to_s } } } #convert to the {id:...,  name:... format that tokeninput.js likes}
        end
    end
  
    def new
    end
  
    def create

        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end
        role = current_user['role']
        if not( role == 'admin' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end

        
            
        #check to see if the person already exists, 
        existing_projectType = ($projectType_collection.find({:projectTypeName => params["project_type"]["projectTypeName"]}).to_a)[0]

        if(!existing_projectType.nil?)
            flash[:notice] = "A projectType with this name exists already"
        else    
            params["project_type"]['createdAt'] = Time.now                
            params["project_type"]['createdBy'] = current_user['_id']
            
            $projectType_collection.insert(params["project_type"])
            #ensure the insert happened
            mongodbLastError = $testDb.get_last_error({:w => 1})
            if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
                raise "mongodb returend error after write, write might not have happened!"  
            end
        end
    

      
        @allProjectTypes = $projectType_collection.find().to_a.reverse
        redirect_to controller:'project_type', action:'index'
    end
end
