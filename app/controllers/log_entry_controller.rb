class LogEntryController < ApplicationController
   
   def add_cr_to_activity_report
       @id = (params["id"].to_i+1).to_s
   end
        
    def new_change_request
        @site = $site_collection.find({"_id" => params["id"].to_i}).to_a[0]
    end
    
    def show_full_activity_report
        @activityReport = $log_entry_collection.find({"_id" => params["id"].to_i}).to_a[0]
    end
    
    def new_activity_report
        @site = $site_collection.find({"_id" => params["id"].to_i}).to_a[0]
    end
    
    def destroy
        tobeDeleted = $log_entry_collection.find({_id: params['id'].to_i}).to_a[0]
        if(get_current_user['role'] == 'admin' or tobeDeleted['person_id'] == get_current_user['_id'])
            $log_entry_collection.remove({_id: params['id'].to_i})
            redirect_to controller:'log_entry', action:'index'
            return
        else
            not get_current_user[:notice] = "you dont have permission to delete this entry, contact and admin"
            redirect_to controller:'log_entry', action:'index'
            return
        end
    end
    
    def edit
        @log_entry = $log_entry_collection.find({"_id" => params["id"].to_i}).to_a[0]
    end
    
    def update
        #find and remove record to be updated
        record = $log_entry_collection.find({"_id" => params["id"].to_i}).to_a[0]
        oldId = record['_id']
        
        #assign new ID by incrementing latest 
        last_entry = $log_entry_collection.find().sort( :_id => :desc ).to_a
        if(last_entry[0].nil? or last_entry.empty?)
            id = 1
        else
            id = last_entry[0]["_id"]+1
        end
        
        params["log_entry"]["_id"] = id
        
        #update respective fields in the old record
        params["log_entry"].each do |key, value|
            if(record.has_key?(key))
                record[key] = value
            end
        end
        
        #check to see if the site id is valid
        if(!siteExists?(record['siteId']))
            return false
        end
        
        #insert new updated record
        $log_entry_collection.insert(record)
        
        mongodbLastError = $testDb.get_last_error({:w => 1})
        if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
            
            raise "mongodb returend error after write, write might not have happened!"  
        else
            $log_entry_collection.remove({'_id' => oldId})
        end
        
        redirect_to controller: "log_entry", action: "index"
    end
    
    def show_cr_written_proof
        log_entry = $log_entry_collection.find_one({'_id' => params['id'].to_i})
        @writtenProofEvidence = log_entry['writtenProofEvidence']
        render 'log_entry/change_request/show_cr_written_proof'
    end
    
    def index
        @whoseEntries = ""
        if(get_current_user.nil?)
            not get_current_user[:notice] = "LOGin to see the LOG!"
            render '/login_session/new'
            return
        elsif(get_current_user['role'] == 'admin')
            if(!params[:id].nil? )
                @log_entries = $log_entry_collection.find({'doer' => params[:id].to_i }).sort( :_id => :desc ).to_a
                @whoseEntries = $person_collection.find("_id" => params[:id].to_i).to_a[0]["email"]
            else
                @log_entries = $log_entry_collection.find().sort( :_id => :desc ).to_a
            end
        else
            @log_entries = $log_entry_collection.find({:person_id => get_current_user['_id']}).sort( :_id => :desc ).to_a
            @whoseEntries = get_current_user['email']
        end  

        respond_to do |format|
            format.html{ render 'index'}
            format.js {  render 'index' }
        end
    end
  
#    def edit
#    end
  
    #delete later november 11 2013
    def show_crew_change_form
        respond_to do |format|
            format.js {render 'log_entry/crew_change/show_crew_change_form'}
        end
    end

    #delete later november 11 2013
    def show_change_request_form
        respond_to do |format|
            format.js {render 'log_entry/change_request/show_change_request_form'}
        end
    end
  
    def create
        params[:log_entry][:person] = get_current_user['email']
        params[:log_entry][:person_id] = get_current_user['_id']
        
        #increment the id of the last entry and use it for this one
        last_entry = $log_entry_collection.find().sort( :_id => :desc ).to_a
        if(last_entry[0].nil? or last_entry.empty?)
            id = 1
        else

            #check for false resubmits due to page refresh or back button by seeing if the last event and current are the same (and ignore _id in comparison or they'd never be)
            #equalize fields that are guaranteed to be different so we can compare this enry with last entry
            params[:log_entry]['_id'] = last_entry[0]['_id']
            params[:log_entry]['time'] = last_entry[0]['time']
            if(params[:log_entry] == last_entry[0])
                redirect_to '/log_entry'
                return
            end
                        
            id = last_entry[0]['_id'] + 1
        end
        
        params[:log_entry]['_id'] = id
        params[:log_entry][:time] = Time.now
      
        #update: can prolly delete this later too, dont redirect them away from a half filled form so reverting to alert message nov 12 soheil
        #check to see if the site id is valid
        #if(!siteExists?(params[:log_entry][:siteId]))
        #    puts('ret falseing')
        #    return false
        #end
        existingSite = $site_collection.find({:siteId => params[:log_entry][:siteId]}).to_a[0]
        if(existingSite.nil?)
            not get_current_user[:error] = "The site id you entered does not match an existing site, let someone with admin rights know!"
            render :js => "alert('The site id you entered does not match an existing site, let someone with admin rights know! (id entered = #{ params[:log_entry][:siteId] })');"
            return
        end
      
        #if it's a crew change event, ensure all emails belong are valid
        #i think crew change stuff can be deleted now, nov 11, soheil
        if(params[:log_entry].has_key? "oldCrew")
            oldCrew = params[:log_entry]["oldCrew"]
            newCrew = params[:log_entry]["newCrew"]    

            emails = oldCrew + " " + newCrew
            if(!validateCrew emails)
                return false
            end
        end
        

        
        #if it's a change request, make sure crNumber is unique, update sep 24: talked to sina, he said the change request number is assiend to us by ericson, and not entered at the time of event entry, so removing this constraint for now to allow potential repeats between different sites, and also allow empty string crNumbers for when we don't have a crNum yet bue event is being entered 
    #    if(params[:log_entry].has_key? "changeRequestNumber")
    #        existingCr = $log_entry_collection.find({:changeRequestNumber => params[:log_entry][:changeRequestNumber]}).to_a[0]
    #        if(!existingCr.nil?)
    #            not get_current_user[:note] = "the change request number you entered exists in the data base already, enter a new cr number"
    #            redirect_to '/log_entry'
    #            return
    #        end
    #    end
        
        
        #perform necessary validations for site activity report event
        if(params[:log_entry]["type"] == "site activity report")
            if(!isStringNumbersOnly?(params[:log_entry]["vehicleStartMilage"]) or
                !isStringNumbersOnly?(params[:log_entry]["vehicleEndMilage"]))
                not get_current_user.now[:notice] = "make sure vehicle start and end milages are numbers only"
                render :js => "alert('make sure vehicle start and end milages are numbers only');"
                return
            end
            
            if(!isStringNumbersOnly?(params[:log_entry]["siteDelay"]))
                not get_current_user.now[:notice] = "make sure site delay in hours is numbers only"
                render :js => "alert('make sure site delay in hours is numbers only');"

            end
        end
        
        
        
        
        
        $log_entry_collection.insert(params[:log_entry])

        #ensure write actually took place by checking mongodb errors. By default mongodb doesn't guarantee write happened
        #mongodb and ruby documentation for get_last_error:
        #http://docs.mongodb.org/manual/reference/command/getLastError/#dbcmd.getLastError
        #http://docs.mongodb.org/manual/reference/write-concern/
        #http://api.mongodb.org/ruby/current/Mongo/DB.html#get_last_error-instance_method
        mongodbLastError = $testDb.get_last_error({:w => 1})
        if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
            raise "mongodb returend error after write, write might not have happened!"  
        end
        
        respond_to do |format|
            format.html{ redirect_to 'index'}
        end
      
       
    end
end
