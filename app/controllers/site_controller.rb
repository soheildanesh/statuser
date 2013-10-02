class SiteController < ApplicationController

    
    def new
    end
  
    def create

        if(current_user['role'] != 'admin')
            flash[:notice] = "only an admin can create a new site!"
            redirect_to :controller => 'log_entry', :action => 'index'
            return
        end
        
        if(!validateCrew params[:site][:crew])
            return
        end
        
        existing_site = ($site_collection.find({:siteId => params[:site][:siteId]}).to_a)[0]
        puts("existing site = #{existing_site}")
        #TODO check to see if the people listed in the crew exist in the db
        if(!existing_site.nil?)
            flash[:notice] = "Site with this ID exists already"
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
        if(current_user['role'] != 'admin')
            flash[:notice] = "only an admin can see the list of sites!"
            redirect_to :controller => 'log_entry', :action => 'index'
            return
        end
        
        @allSites = $site_collection.find().to_a.reverse
        puts("all sites = #{@allSites}")
    end
end