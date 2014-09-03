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
        if( get_current_user.nil?)
            redirect_to controller:'login_session', action:'new'
            return
        elsif( get_current_user['role'] != 'admin')
            not get_current_user[:error] = 'User not authorized'
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
         
         if( get_current_user.nil?)
             not get_current_user[:notice] = "User not logged in"
             render controller: 'login_session', :action => 'new'
             return
         end
         role =get_current_user['role']
         if  false and not( role == 'admin' or role == 'project controller')
             not get_current_user[:error] = "User not authorized"
             redirect_to action: 'index'
             return
         end

        
       # if(!validateCrew params[:site][:crew])
       #     return
       # end
        
        existing_site = ($site_collection.find({:customerId => params[:site][:customerId], :customerSiteId => params[:site][:customerSiteId] }).to_a)[0]

        #TODO check to see if the people listed in the crew exist in the db
        if(!existing_site.nil?)
            not get_current_user.now[:notice] = "Site with this ID exists already"
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
            
            params[:site][:person_id] =get_current_user['_id']
            
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
        
        if( get_current_user.nil?)
            not get_current_user[:notice] = "User not logged in"
            render controller: 'project' , :action => 'index'
            return
        end
        role =get_current_user['role']
        if  not( role == 'admin' or role == 'project controller' or role == 'project manager' or role == 'project manager admin')
            not get_current_user[:error] = "User not authorized"
            render controller: 'project' , :action => 'index'
            return
        end
        
        if( get_current_user.nil?)
            not get_current_user[:notice] = "LOGin to see the LOG!"
            render '/login_session/new'
            return
        else
            if(params.has_key?("q")) #(initially at least) used by tokeninput.js plugin
                searchString = ".*#{params['q']}.*"

                @allSites = $site_collection.find({'customerSiteId' => Regexp.new(searchString, "i") })
                
                #@allSites = $site_collection.find({'customerSiteId' => Regexp.new(searchString, "i"), "customerId" =>get_current_user['customerMode']['customerId'] }) #not doint customer mode any more
            elsif( get_current_user['role'] == 'admin' or true) #NOTE: for now everyone can see all sites, for daily activity report site id autocomplete
                @allSites = $site_collection.find().to_a.reverse
            else
               
            end    
        end
        
        respond_to do |format|
            format.html
            format.json { render :json => @allSites.map{ |site| { 'name' => site['customerSiteId'], 'id'=> site["_id"] } } } #convert to the {id:...,  name:... format that tokeninput.js likes}
        end
    end
end