class SiteController < ApplicationController
    
    def siteTasks
        tasks = [
            {"id" => "antenna adjustment","name" => "antenna adjustment"},
            {"id" => "switchboard change","name" => "switchboard change"},
            {"id" => "some other task","name" => "some other task"},
        ]
        render :json => tasks
    end
    
    def show_options
       @_id =  params[:id]
    end
        
        

    def destroy
        if(current_user.nil?)
            redirect_to controller:'login_session', action:'new'
            return
        elsif(current_user['role'] != 'admin')
            redirect_to controller:'login_session', action:'new'
            return
        else
            $site_collection.remove({_id: params['id'].to_i})
            redirect_to controller:'site', action:'index'
            return
        end
    end
    
    def edit
        @site = $site_collection.find({"_id" => params['id'].to_i}).to_a[0]
    end
    
    def update
         #find and remove record to be updated
         record = $site_collection.find({"_id" => params["id"].to_i}).to_a[0]
         oldId = record['_id']

         #assign new ID by incrementing latest 
         last_entry = $site_collection.find().sort( :_id => :desc ).to_a
         if(last_entry[0].nil? or last_entry.empty?)
             id = 1
         else
             id = last_entry[0]["_id"]+1
         end

         params["site"]["_id"] = id

         #update respective fields in the old record
         params["site"].each do |key, value|
             if(record.has_key?(key))
                 record[key] = value
             end
         end

         #check to see if the site id is valid
        # if(!siteExists?(record['siteId']))
        #     return false
        # end

         #insert new updated record
         $site_collection.insert(record)

         mongodbLastError = $testDb.get_last_error({:w => 1})
         if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)

             raise "mongodb returend error after write, write might not have happened!"  
         else
             $site_collection.remove({'_id' => oldId})
         end

         redirect_to controller: "site", action: "index"
     end
     
       
     def create

        if(current_user['role'] != 'admin')
            flash[:notice] = "only an admin can create a new site!"
            redirect_to :controller => 'log_entry', :action => 'index'
            return
        end
        
       # if(!validateCrew params[:site][:crew])
       #     return
       # end
        
        existing_site = ($site_collection.find({:siteId => params[:site][:siteId]}).to_a)[0]

        #TODO check to see if the people listed in the crew exist in the db
        if(!existing_site.nil?)
            flash.now[:notice] = "Site with this ID exists already"
        else
            
            #produce an incremented id
            last_entry = $site_collection.find().sort( :_id => :desc ).to_a
            if(last_entry.nil? or last_entry.empty?)
                id = 1
            else
                id = last_entry[0]['_id'] + 1
            end
            params[:site]['_id'] = id
            
            params[:site][:time] = Time.now
            
            params[:site][:person_id] = current_user['_id']
            
            $site_collection.insert(params[:site])
            
            #ensure the insert happened
            mongodbLastError = $testDb.get_last_error({:w => 1})
            if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
                raise "mongodb returend error after site creation, write might not have happened!"  
            end
        end
    
        @allSites = $site_collection.find().to_a.reverse
        render 'index'
    end
  
    def index
        if(current_user.nil?)
            flash[:notice] = "LOGin to see the LOG!"
            render '/login_session/new'
            return
        elsif(current_user['role'] == 'admin')
            @allSites = $site_collection.find().to_a.reverse
        else
            s1 = $site_collection.find({"projMan" => current_user['_id'].to_s}).to_a.reverse
            s2 = $site_collection.find({constMan: current_user['email']}).to_a.reverse
            s3 = $site_collection.find({copInCharge: current_user['email']}).to_a.reverse
            puts("****")
            puts(s1)
            puts(s2)
            puts(s3)
            puts("****")
            @allSites = s1 + s2 + s3
        end        
    end
end