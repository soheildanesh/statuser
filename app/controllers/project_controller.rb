class ProjectController < ApplicationController
    def new
        @projId3s = genSamllUniqId $project_collection, 'projId3s'
    end
    
    def show
        id = params['id']
        @project = $project_collection.find({:_id => BSON::ObjectId(id) } ).to_a[0]
        
        @projectCustomerName = $customer_collection.find_one(:_id => BSON::ObjectId(@project['customerId']))['customerName']
        
        if( @projectCustomerName == "ericsson")
            @wos = Array.new
            @project.each do |key, value|
                if(key.include? 'wo_id')
                    wo = $wo_collection.find(:_id => value).to_a[0]
                    if(not wo.nil?)
                        @wos << wo
                    end   
                end
            end
            @wos.sort!{|x,y| y['createdAt'] <=> x['createdAt']}
        end
        
        if( @projectCustomerName  == "sprint")
            #get the milestone list for this project
        end
         
        render "show_#{@projectCustomerName}"
         
    end
    
    def destroy
        tobeDeleted = $project_collection.find({_id: params['id'].to_i}).to_a[0]
        if(current_user['role'] == 'admin' or tobeDeleted['createdBy'] == current_user['_id'])
            $project_collection.remove({_id: BSON::ObjectId(params['id'])})
            redirect_to controller:'project', action:'index'
            return
        else
            flash[:error] = "you dont have permission to delete this entry, contact and admin"
            redirect_to controller:'project', action:'index'
            return
        end
    end
    
    def create
        if( params['project'].nil? )
            return nil
        end
        
        #TODO check admin status so not just any one can create new proj
        
        #create new project and add quoteId to it
        @project = Hash.new()
        @project = params['project']
        @project['createdAt'] = Time.now
        @project['createdBy'] = $current_user['_id']
        
        
        
        okToCreate = true

        #make sure all fields have been entered before creating object
        missingKey = ""
        @project.each do |key, value|
          if value.nil?
              okToCreate = false
              missingKey = key
          elsif value.to_s.empty?
              okToCreate = false
              missingKey = key
          end

        end

        if(not okToCreate)
            flash[:error] = "Project could not be created because not all ( #{missingKey}) fields required for a new project were entered."
        end

        if(okToCreate)
          #make sure the project name is unique
          project = $project_collection.find({'projName' => @project['projName'] } ).to_a[0]
          if(project.nil?)

          elsif(project.empty?)

          else
              okToCreate = false
              flash[:error] = "Poject could not be created becuse project's name already exists in the databse, please enter a unique project name"
          end
        end

        if(okToCreate)
          flash[:error] = ""
        end

        if(okToCreate)
          #@project['3sId'] = id3s

          projectId = $project_collection.insert(@project)

          redirect_to action: 'index'
        else
          redirect_to action: 'new'
        end
    end
    
    def edit
         @project = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
    end
    
    def update
        
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
        record = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
        
        params['project'].each do |key, value| 
            if key == '_id'
                next
            end
            record[key] = value
        end
        
        $project_collection.save(record)
   
        redirect_to controller: "project", action: "show", id: record['_id']
        
     end
    
    def index
        if(current_user.nil?)
             flash[:notice] = "Have to be admin user for this"
             render '/login_session/new'
             return
         elsif(current_user['role'] == 'admin')
             if(current_user['customerMode']['customerId'] == "All Customers")
                 @projects = $project_collection.find().sort( :_id => :desc ).to_a
                 @customerInMode = "All Customers"
             else
                 @projects = $project_collection.find({"customerId" => current_user['customerMode']['customerId'] }).sort( :_id => :desc ).to_a
                 @customerInMode = $customer_collection.find_one( {:_id => BSON::ObjectId(current_user['customerMode']['customerId']) } )['customerName']
             end
         end
         
         render "index"
    end
    
    def newSearch
        
    end
    
    def search
        searchHash = Hash.new
        
        params['project'].each do |key,value|
            if(value.nil? or value.empty?)
                next
            end
            searchHash[key] = value
        end
        
        @projects = $project_collection.find(searchHash).sort( :_id => :desc ).to_a
        render 'index'
    end
end