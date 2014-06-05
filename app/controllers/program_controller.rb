class ProgramController < ApplicationController
  
    def destroy
        if(current_user.nil?)
            flash[:notice] = "log in to delete a propgram"
            redirect_to  action:'index'
            return
        elsif(current_user['role'] != 'admin')
            flash[:notice] = "only an admin can delete a propgram"
            redirect_to action:'index'
            return
        else
            $program_collection.remove({:_id => BSON::ObjectId(params['id']) })
            flash['notice'] = 'Program Deleted'
            redirect_to controller:'program', action:'index'
            return
        end
    end
    
    def show

    end
  
    def index

        if(params.has_key?("q"))
            searchString = ".*#{params['q']}.*"
            @programs = $program_collection.find({'programName' => Regexp.new(searchString)})
        else
            @programs = $program_collection.find()
        end
            
        
        respond_to do |format|
            format.html
            format.json { render :json => @programs.map{ |program| { 'name' => program['programName'], 'id'=> program['_id'].to_s } } } #convert to the {id:...,  name:... format that tokeninput.js likes}
        end
    end
  
    def new
    end
  
    def create
        
        if(current_user.nil?)
            flash[:notice] = "log in to create a propgram"
            render :controller => 'project', :action => 'index'
            return
        
        elsif( current_user['role'] != 'admin')
        
            flash[:notice] = "only an admin can create a program"
            render :controller => 'project', :action => 'index'
            return
        
        else
            
            #check to see if the person already exists, 
            existing_program = ($program_collection.find({:programName => params[:program][:programName]}).to_a)[0]

            if(!existing_program.nil?)
                flash[:notice] = "A program with this name exists already"
            else
            
                
                params[:program]['createdAt'] = Time.now                
                params[:program]['createdBy'] = current_user['_id']
                
                $program_collection.insert(params[:program])
                #ensure the insert happened
                mongodbLastError = $testDb.get_last_error({:w => 1})
                if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
                    raise "mongodb returend error after write, write might not have happened!"  
                end
            end
        
        end
      
        @allPrograms = $program_collection.find().to_a.reverse
        redirect_to controller:'program', action:'index'
    end
end
