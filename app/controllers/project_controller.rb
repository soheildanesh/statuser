class ProjectController < ApplicationController
    def new
        
        
        
        
        #make project off of quote, march 29
        #
        #if( not params["quote_id"].nil?)
        #    @quote = $quote_collection.find({ :_id => BSON::ObjectId(params['quote_id']) } ).to_a[0]
        #end
             
        #indicate quote has been accepted (acceptedQuote['accepted?'] = true) but no internal project has been created for it yet 
        #acceptedQuote = Hash.new
        #@quote.each do |key, value|
        #    acceptedQuote[key] = value
        #end
        #acceptedQuote['accepted?'] = true
        #$quote_collection.save(acceptedQuote)
    end
    
    def show
        id = params['id']
        @project = $project_collection.find({:_id => BSON::ObjectId(id) } ).to_a[0]
        
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
        @project['createdBy'] = $current_user
        
        
        
        okToCreate = true

        #make sure all fields have been entered before creating object
        @project.each do |key, value|
          if value.nil?
              okToCreate = false
          elsif value.to_s.empty?
              okToCreate = false
          end
        end

        if(not okToCreate)
            flash[:error] = "Project could not be created because not all fields required for a new project were entered."
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

        #generate a unique random 3s id
        id3s = rand(1000000)
        idIsUniq = false
        while(not idIsUniq)
          project = $project_collection.find({'id3s' => id3s }).to_a[0]
          if(project.nil?)
              idIsUniq = true
          elsif(project.empty?)
              idIsUniq = true
          else
              id3s = rand(1000000)
              puts("Trying to generate uniqe random 3sId for project")
          end
        end

        if(okToCreate)
          @project['3sId'] = id3s

          projectId = $project_collection.insert(@project)

          redirect_to action: 'index'
        else
          redirect_to action: 'new'
        end
    end
    
    def index
        if(current_user.nil?)
             flash[:notice] = "Have to be admin user for this"
             render '/login_session/new'
             return
         elsif(current_user['role'] == 'admin')
             @projects = $project_collection.find().sort( :_id => :desc ).to_a
         end
    end
end